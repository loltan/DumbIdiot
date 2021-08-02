local check = {}

function check.runCheck()
	_, result = hs.execute("netstat -anp tcp | grep LISTEN | grep -w \"\\.5900\"")
	if result then
		return false, "‼️ Screen sharing/remote management is enabled"
	else
		return true
	end
end

return check