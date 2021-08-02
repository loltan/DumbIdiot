local check = {}

function check.runCheck()
    hs.application.enableSpotlightForNameSearches(true)
	if hs.application.find("Little Snitch") then
		return true
	else 
		return false, "‼️ Little Snitch is not running"
	end
end

return check