local check = {}

function check.runCheck()
	_, result = hs.execute("csrutil status | grep enabled")
	if result then
		return true
	else
		return false, "‼️ SIP is diabled"
	end
end

return check