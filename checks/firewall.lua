local check = {}

function check.runCheck()
	result = hs.execute("defaults read /Library/Preferences/com.apple.alf globalstate")
	if (string.sub(result, 1, 1) == "1") then
		return true
	else 
		return false, "‼️ Firewall is off"
	end
end

return check