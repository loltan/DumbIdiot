local check = {}

function check.runCheck()
	_, result = hs.execute("fdesetup status | grep On")
	if result then
		return true
	else
		return false, "‼️ FileVault is disabled"
	end
end

return check