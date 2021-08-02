local check = {}

function check.runCheck()
	_, result = hs.execute("netstat -anp tcp | grep LISTEN | grep -w \"\\.22\"")
	if result then
		return false, "‼️ Remote login is enabled"
	else
		return true
	end
end

return check