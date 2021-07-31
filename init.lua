-------------------------------------------------------------------------
--                          Dumb Idiot                                 --
-- Dumb Idiot - a tool to check for common hardening misconfigurations --
-------------------------------------------------------------------------

local obj = {}
obj.__index = obj

--------------
-- Metadata --
--------------
obj.name = "DumbIdiot"
obj.version = "0.2.1"
obj.author = "Zoltan Madarassy @loltan"
obj.homepage = "https://github.com/loltan/DumbIdiot"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-------------------------------
-- Global vars and constants --
-------------------------------
obj.notificationAlwaysShow = true
obj.startEnabled = true
-- How often are we running all checks (in minutes)
obj.checkTimer = 30
obj.snooze = false
obj.configDir = hs.configdir .. "/Spoons/DumbIdiot.spoon"
obj.configFile = "dumbidiot.conf"
obj.notificationImage = hs.image.imageFromPath(obj.configDir .. "/bender.png")
obj.allGood = true

------------------------------
-- Required Spoon functions --
------------------------------
function obj:init()
	self.menu = hs.menubar.new(self.notificationAlwaysShow)
	if not self.notificationAlwaysShow then
		self.menu:removeFromMenuBar()
 	end
	
	self:start()
end

function obj:start()
	if obj.startEnabled then
		self:runChecks()
		checkTimer = hs.timer.new((obj.checkTimer * 60), function() self:runChecks() end)
		checkTimer:start()
	end
end

function obj:stop()
	-- TODO: add a hotkey to toggle checks
	obj.startEnabled = false
end

function obj:bindHotKeys(mapping)
	if (self.hotkey) then
		self.hotkey:delete()
	end
	local mods = mapping["runChecks"][1]
	local key = mapping["runChecks"][2]

	self.hotkey = hs.hotkey.bind(mods, key, function() self:runChecks() end)
end

----------------------
-- Helper functions --
----------------------

function obj:snoozeNotifications()
	if (not obj.allGood) then
		obj.snooze = true
		hs.alert.show("Dumb Idiot notifications snoozed")
	end
end

function obj:sendNotification()
	hs.notify.register("Snooze", function() self:snoozeNotifications() end)
	alert = hs.notify.new(function() self:snoozeNotifications() end)
	alert:title("Dumb Idiot alert")
	alert:subTitle("Things ain't so funky, click the ambulance!")
	alert:hasActionButton(true)
	alert:actionButtonTitle("Snooze")
	alert:withdrawAfter(0)
	--print(obj.configDir .. "/bender.png")
	alert:contentImage(obj.notificationImage)
	alert:send()
end

function obj:updateMenubar(menuItems, allGood)
	-- Set the menubar icon according to the results of the check, including the list of failed checks
	self.menu:setMenu(menuItems)
	if not obj.allGood then
		self.menu:setTitle("🚑")
	else
		self.menu:setTitle("😎")
	end
end

function obj:split(s, delimiter)
    result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

----------------
-- THE CHECKS --
----------------
function obj:runChecks()
	menuItems = {}
	obj.allGood = true
	
	if not self:isApplicationClosed("Docker") then
		table.insert(menuItems, {title = "‼️ Docker is running"})
		obj.allGood = false
	end
	
	-- BUG: Apparently Hammerspoon loads before Little Snitch so when the computer is restarted this check will fail.
	-- Manually running the check again will get rid of the ambulance though.
	if self:isApplicationClosed("Little Snitch") then
		table.insert(menuItems, {title = "‼️ Little Snitch is not running"})
		obj.allGood = false
	end
	
	if not self:isProcessStopped("httpd") then
		table.insert(menuItems, {title = "‼️ Apache is running"})
		obj.allGood = false
	end
	
	-- Probably not a good check in case the SSH port number is changed in /etc/ssh/sshd_conf, but 
	-- as the sshd is only started by launchd when a connection is received, this is a good enough
	-- first pass
	if not self:isPortClosedTcp("22") then
		table.insert(menuItems, {title = "‼️ Remote login is enabled"})
		obj.allGood = false
	end
	
	-- Same as above, just with VNC.
	if not self:isPortClosedTcp("5900") then
		table.insert(menuItems, {title = "‼️ Screen sharing/remote managmenet is enabled"})
		obj.allGood = false
	end
	
	if not self:isPortClosedUdp("69") then
		table.insert(menuItems, {title = "‼️ TFTP is enabled"})
		obj.allGood = false
	end

	if ((not self:isPortClosedTcp("445")) and (not self:isPortClosedTcp("88"))) then
		table.insert(menuItems, {title = "‼️ File sharing is enabled"})
		obj.allGood = false
	end
	
	if not self:isFirewallOn() then 
		table.insert(menuItems, {title = "‼️ Firewall is off"})
		obj.allGood = false
	end
	
	if not self:isSIPEnabled() then
		table.insert(menuItems, {title = "‼️ SIP is diabled"})
		obj.allGood = false
	end
	
	if not self:isFileVaultEnabled() then
		table.insert(menuItems, {title = "‼️ FileVault is disabled"})
		obj.allGood = false
	end

	if not self:isGuestAccountDisabled() then
		table.insert(menuItems, {title = "‼️ Guest account is enabled"})
		obj.allGood = false
	end

	if not self:isSystemProxyEnabled() then
		table.insert(menuItems, {title = "‼️ System-wide web proxy is on"})
		obj.allGood = false
	end

	if not self:isStaticIPConfigured() then
		table.insert(menuItems, {title = "‼️ Manual IP address is set"})
		obj.allGood = false
	end
	
	if not self:isDirEmpty("/etc/resolver") then
		table.insert(menuItems, {title = "‼️ Hardcoded /etc/resolver entries present"})
		obj.allGood = false
	end

	if not self:isHostsFileClean() then
		table.insert(menuItems, {title = "‼️ Non-standard /etc/hosts entries present"})
		obj.allGood = false
	end

	self:updateMenubar(menuItems, obj.allGood)

	if obj.allGood then
		obj.snooze = false
	end

	if ((not obj.allGood) and (not obj.snooze)) then
		self:sendNotification()
	end
end

-- TODO: If the interface is configured to be off after it was on manual, this test will still fail. It's probably an edge-case though
-- so not a high priority bug atm.
function obj:isStaticIPConfigured()
	happy = true
	offendingNetworkServices = {}
	res = hs.execute("networksetup -listallnetworkservices")
	networkServices = self:split(res, "\n")

	for service = 2, #networkServices-1 do
		proxySettings = hs.execute("networksetup -getinfo \"" .. networkServices[service] .. "\" | grep \"Manual Configuration\"")
		if #proxySettings ~= 0 then
			happy = false
			table.insert(offendingNetworkServices, networkServices[service])
		end
	end

	if happy then
		return true
	else
		return false
	end
end

-- TODO: Right now we just return a boolean but we also have the list of network services where the check fails, so return those too,
-- probably best if in the notification's body.
function obj:isSystemProxyEnabled()
	happy = true
	offendingNetworkServices = {}
	res = hs.execute("networksetup -listallnetworkservices")
	networkServices = self:split(res, "\n")

	for service = 2, #networkServices-1 do
		proxySettings = hs.execute("networksetup -getwebproxy \"" .. networkServices[service] .. "\" | grep \"Enabled: Yes\"")
		if #proxySettings ~= 0 then
			happy = false
			table.insert(offendingNetworkServices, networkServices[service])
		end
	end

	if happy then
		return true
	else
		return false
	end
end

function obj:isFirewallOn()
	result = hs.execute("defaults read /Library/Preferences/com.apple.alf globalstate")
	if (string.sub(result, 1, 1) == "1") then
		return true
	else 
		return false
	end
end

function obj:isProcessStopped(processName)
	_, result = hs.execute("ps aux | grep " .. processName .. " | grep -v grep")
	if result then 
		return false
	else
		return true
	end
end

function obj:isPortClosedTcp(portNumber)
	_, result = hs.execute("netstat -anp tcp | grep LISTEN | grep -w \"\\."..portNumber.."\"")
	if result then
		return false
	else
		return true
	end
end	

function obj:isPortClosedUdp(portNumber)
	_, result = hs.execute("netstat -anp udp | grep LISTEN | grep -w \"\\."..portNumber.."\"")
	if result then
		return false
	else
		return true
	end
end	

function obj:isSIPEnabled()
	_, result = hs.execute("csrutil status | grep enabled")
	if result then
		return true
	else
		return false
	end
end

function obj:isFileVaultEnabled()
	_, result = hs.execute("fdesetup status | grep On")
	if result then
		return true
	else
		return false
	end
end

function obj:isDirEmpty(path)
	result = hs.execute("ls "..path)
	if result == nil or result == '' then
		return true
	else
		return false
	end
end

function obj:isGuestAccountDisabled()
	resultLogin = string.sub(hs.execute("defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled"), 1, 1)
	resultShareSMB = string.sub(hs.execute("defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server.plist AllowGuestAccess"), 1, 1)
	if ((resultLogin == "1") or (resultShareSMB == "1")) then
		return false
	else
		return true
	end
end

function obj:isApplicationClosed(applicationName)
	hs.application.enableSpotlightForNameSearches(true)
	if hs.application.find(applicationName) then
		return false
	else 
		return true
	end
end

function obj:isHostsFileClean()
	--can't believe LUA doesn't have a "continue" control flow
	for line in io.lines("/etc/hosts") do
		if line:sub(1,1) == '#' then
		elseif string.find(line, "127.0.0.1", 0, true) then
		elseif string.find(line, "255.255.255.255", 0, true) then
		elseif string.find(line, "::1", 0, true) then
		else
			return false
		end
	end
	return true
end	

return obj
