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
obj.version = "v1.0"
obj.author = "Zoltan Madarassy @loltan"
obj.homepage = "https://github.com/loltan/DumbIdiot"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-------------------------------
-- Global vars and constants --
-------------------------------
-- TODO: add a hotkey to toggle checks
obj.startEnabled = true
obj.snooze = false
-- BUG: the . in DumbIdiot.spoon doesn't seem to cooperate with require() so I can't put
-- the config file or the checks in the Spoon itself right now. Figure out why.
obj.configDir = hs.configdir .. "/Spoons/DumbIdiot.spoon"
obj.notificationImage = hs.image.imageFromPath(obj.configDir .. "/bender.png")
-- BUG: the . in DumbIdiot.spoon doesn't seem to cooperate with require() so I can't put
-- the config file or the checks in the Spoon itself right now. Figure out why.
obj.checksFolder = hs.configdir .. '/Spoons/DumbIdiot.spoon/checks/'
obj.allGood = true
obj.config = {}

------------------------------
-- Required Spoon functions --
------------------------------
function obj:init()
	local f,err = loadfile("dumbidiot.conf", "t", obj.config)
	if f then
		f()
	else
		print(err)
	end

	-- TODO: Based on the menubarAlwaysShow setting only show the ambulance when a check fails
	self.menu = hs.menubar.new(obj.config["settings"].menubarAlwaysShow)
	if not obj.config["settings"].menubarAlwaysShow then
		self.menu:removeFromMenuBar()
 	end
	
	self:start()
end

function obj:start()
	if obj.startEnabled then
		self:runChecks()
		checkTimer = hs.timer.new((obj.config["settings"].checkTimer * 60), function() self:runChecks() end)
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
	alert:contentImage(obj.notificationImage)
	alert:send()
end

function obj:updateMenubar(menuItems, allGood)
	self.menu:setMenu(menuItems)
	if not obj.allGood then
		self.menu:setTitle("🚑")
	else
		self.menu:setTitle("😎")
	end
end

----------------
-- THE CHECKS --
----------------
function obj:runChecks()
	menuItems = {}
	obj.allGood = true
	
	for i=1, #obj.config["checks"] do 
		checkString = "checks." .. obj.config["checks"][i].name
		if obj.config["checks"][i].enabled then
			check = require(checkString)
			result, errorString = check.runCheck()
			if not result then
				table.insert(menuItems, {["title"]=errorString})
				obj.allGood = false
			end
		end
	end

	self:updateMenubar(menuItems, obj.allGood)

	if obj.allGood then
		obj.snooze = false
	end

	if ((not obj.allGood) and (not obj.snooze)) then
		self:sendNotification()
	end
end

return obj
