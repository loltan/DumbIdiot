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
obj.version = "v1.2"
obj.author = "Zoltan Madarassy @loltan"
obj.homepage = "https://github.com/loltan/DumbIdiot"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-------------------------------
-- Global vars and constants --
-------------------------------
-- TODO: add a hotkey to toggle checks
obj.startEnabled = true
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

	self.menu = hs.menubar.new()
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
function obj:snoozeNotifications(checkName)
	if (not obj.allGood) then
		
		for i, v in ipairs(obj.config["checks"]) do
			if obj.config["checks"][i].name == checkName then
				obj.config["checks"][i].snoozed = true
			end
		end
	
	end
end

function obj:sendNotification(checkName, errorMessage)
	hs.notify.register("Snooze", function() self:snoozeNotifications(checkName) end)
	alert = hs.notify.new(function() self:snoozeNotifications(checkName) end)
	alert:title("Dumb Idiot alert")
	alert:subTitle(errorMessage)
	alert:hasActionButton(true)
	alert:actionButtonTitle("Snooze")
	alert:withdrawAfter(0)
	alert:contentImage(obj.notificationImage)
	alert:send()
end

function obj:updateMenubar(menuItems, allGood)
	if not obj.config["settings"].menubarAlwaysShow then
		self.menu:removeFromMenuBar()
	end
	
	if not obj.allGood then
		self.menu:returnToMenuBar()
		self.menu:setTitle("🚑")
	elseif obj.config["settings"].menubarAlwaysShow then
		self.menu:setTitle("😎")
	end
	
	self.menu:setMenu(menuItems)
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
				if not obj.config["checks"][i].snoozed then
					self:sendNotification(obj.config["checks"][i].name, errorString)
				end
				obj.allGood = false
			end
		end
	end

	self:updateMenubar(menuItems, obj.allGood)

	if obj.allGood then
		for i, v in ipairs(obj.config["checks"]) do
			obj.config["checks"][i].snoozed = false
		end
	end

end

return obj