local check = {}

function check.runCheck()
    hs.application.enableSpotlightForNameSearches(true)
    print(hs.application.find("Docker Desktop"))
	if hs.application.find("Docker Desktop") then
		return false, "‼️ Docker is running"
	else 
		return true
	end
end

return check