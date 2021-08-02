local check = {}

function check.runCheck()
	_, result = hs.execute("netstat -anp udp | grep LISTEN | grep -w \"\\.69\"")
	if result then
		return false, "‼️ TFTP is enabled"
	else
		return true
	end
end

return check