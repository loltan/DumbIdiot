local check = {}

function check.runCheck()
	result = hs.execute("ls /etc/resolver")
	if result == nil or result == '' then
		return true
	else
		return false, "‼️ Hardcoded /etc/resolver entries present"
	end
end

return check