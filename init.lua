--- === Dumb Idiot === ---
---
--- Dumb Idiot - a tool to check for common hardening misconfigurations


local obj = {}
obj.__index = obj

--------------
-- Metadata --
--------------
obj.name = "DumbIdiot"
obj.version = "0.1"
obj.author = "Zoltan Madarassy @loltan"
obj.homepage = "https://github.com/loltan/DumbIdiot"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-------------------------------
-- Global vars and constants --
-------------------------------
obj.alwaysShow = true

-- Pasteboard settings
obj.periodicallyClearPasteboard = true
obj.pasteboardTimer = 1
-- How often are we running all checks (in minutes)
obj.checkTimer = 30
obj.snooze = false

------------------------------
-- Required Spoon functions --
------------------------------
function obj:init()
	self.menu = hs.menubar.new(self.alwaysShow)
	if not self.alwaysShow then
		self.menu:removeFromMenuBar()
 	end

	-- I should probably put these in start() and also make a stop() to align with Spoon guidelines
	self:runChecks()
 	checkTimer = hs.timer.new((obj.checkTimer * 60), function() self:runChecks() end)
 	checkTimer:start()
 	pasteboardTimer = hs.timer.doEvery((obj.pasteboardTimer * 60), function() self:clearPasteboard() end)
 	pasteboardTimer:start()
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
function obj:runChecks()
	menuItems = {}
	allGood = true
	
	if obj.periodicallyClearPasteboard then 
		table.insert(menuItems, {title = "✅ Automatically clear pasteboard", fn = function() obj.periodicallyClearPasteboard = false end})
	else
		table.insert(menuItems, {title = "❌ Automatically clear pasteboard", fn = function() obj.periodicallyClearPasteboard = true end})
	end
	
	if self:applicationCheck("Docker") then
		table.insert(menuItems, {title = "‼️ Docker is running"})
		allGood = false
	end
	
	if not self:applicationCheck("Little Snitch") then
		table.insert(menuItems, {title = "‼️ Little Snitch is not running"})
		allGood = false
	end
	
	if self:processCheck("httpd") then
		table.insert(menuItems, {title = "‼️ Apache is running"})
		allGood = false
	end
	
	-- Probably not a good check in case the SSH port number is changed in /etc/ssh/sshd_conf, but 
	-- as the sshd is only started by launchd when a connection is received, this is a good enough
	-- first pass
	if self:portCheck("22") then
		table.insert(menuItems, {title = "‼️ Remote login is enabled"})
		allGood = false
	end
	
	-- Same as above, just with VNC.
	if self:portCheck("5900") then
		table.insert(menuItems, {title = "‼️ Screen sharing/remote managmenet is enabled"})
		allGood = false
	end

	if (self:portCheck("88") and self:portCheck("445")) then
		table.insert(menuItems, {title = "‼️ File sharing is enabled"})
		allGood = false
	end
	
	if not self:firewallCheck() then 
		table.insert(menuItems, {title = "‼️ Firewall is off"})
		allGood = false
	end
	
	if not self:checkSIP() then
		table.insert(menuItems, {title = "‼️ SIP is diabled"})
		allGood = false
	end
	
	if not self:checkFileVault() then
		table.insert(menuItems, {title = "‼️ FileVault is disabled"})
		allGood = false
	end

	if not self:checkGuestAccount() then
		table.insert(menuItems, {title = "‼️ Guest account is enabled"})
		allGood = false
	end

	if not self:systemProxyCheck() then
		table.insert(menuItems, {title = "‼️ System-wide web proxy is on"})
		allGood = false
	end

	if not self:manualIPcheck() then
		table.insert(menuItems, {title = "‼️ Manual IP address is set"})
		allGood = false
	end

	self:updateMenubar(menuItems, allGood)

	if ((not allGood) and (not obj.snooze)) then
		self:sendNotification()
	end

	if allGood then
		obj.snooze = false
	end
end

function obj:snoozeNotifications()
	hs.alert.show("Dumb Idiot notifications snoozed")
	obj.snooze = true
end

function obj:sendNotification()
	hs.notify.register("Snooze", function() self:snoozeNotifications() end)
	alert = hs.notify.new(function() self:snoozeNotifications() end)
	alert:title("Dumb Idiot alert")
	alert:subTitle("Shit ain't so funky, click the ambulance!")
	alert:hasActionButton(true)
	alert:actionButtonTitle("Snooze")
	alert:withdrawAfter(0)
	alert:send()
end

function obj:updateMenubar(menuItems, allGood)
	-- Set the menubar icon according to the results of the check, including the list of failed checks
	self.menu:setMenu(menuItems)
	if not allGood then
		self.menu:setTitle("🚑")
		--hs.notify.show("Dumb Idiot alert", "", "Things ain't so funky")
	else
		self.menu:setTitle("😎")
	end
end
----------------
-- THE CHECKS --
----------------
-- TODO: If the interface is configured to be off after it was on manual, this test will still fail. It's probably an edge-case though
-- so not a high priority bug atm.
function obj:manualIPcheck()
	happy = true
	offendingNetworkServices = {}
	res = hs.execute("networksetup -listallnetworkservices")
	networkServices = self:split(res, "\n")

	for service = 2, #networkServices-1 do
		proxySettings = hs.execute("networksetup -getinfo \"" .. networkServices[service] .. "\" | grep \"Manual Configuration\"")
		if #proxySettings ~= 0 then
			happy = false
			table.insert(offendingNetworkServices, networkServices[service])
			hs.alert.show(networkServices[service])
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
function obj:systemProxyCheck()
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

function obj:split(s, delimiter)
    result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function obj:firewallCheck()
	result = hs.execute("defaults read /Library/Preferences/com.apple.alf globalstate")
	if (string.sub(result, 1, 1) == "1") then
		return true
	else 
		return false
	end
end

function obj:processCheck(processName)
	_, result = hs.execute("ps aux | grep " .. processName .. " | grep -v grep")
	if result then 
		return true
	else
		return false
	end
end

function obj:portCheck(portNumber)
	_, result = hs.execute("netstat -an | grep LISTEN | grep ."..portNumber)
	if result then
		return true
	else
		return false 
	end
end	

function obj:checkSIP()
	_, result = hs.execute("csrutil status | grep enabled")
	if result then
		return true
	else
		return false
	end
end

function obj:checkFileVault()
	_, result = hs.execute("fdesetup status | grep On")
	if result then
		return true
	else
		return false
	end
end

function obj:checkGuestAccount()
	resultLogin = string.sub(hs.execute("defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled"), 1, 1)
	resultShareSMB = string.sub(hs.execute("defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server.plist AllowGuestAccess"), 1, 1)
	if ((resultLogin == "0") and (resultShareSMB == "0")) then
		return true
	else
		return false
	end
end

function obj:applicationCheck(applicationName)
	hs.application.enableSpotlightForNameSearches(true)
	if hs.application.find(applicationName) then
		return true
	else 
		return false
	end
end

function obj:clearPasteboard()
	if periodicallyClearPasteboard then
		hs.pasteboard.clearContents()
		hs.notify.show("Dumb Idiot alert", "", "Pasteboard cleared")
	end
end

return obj