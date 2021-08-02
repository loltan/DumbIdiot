local check = {}

function check.runCheck()
	_, smb = hs.execute("netstat -anp tcp | grep LISTEN | grep -w \"\\.445\"")
    _, afs = hs.execute("netstat -anp tcp | grep LISTEN | grep -w \"\\.88\"")
	if smb and afs then
		return false, "‼️ File sharing is enabled"
	else
		return true
	end
end

return check