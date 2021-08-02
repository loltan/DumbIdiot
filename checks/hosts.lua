local check = {}

function check.runCheck()
	--can't believe LUA doesn't have a "continue" control flow
	for line in io.lines("/etc/hosts") do
		if line:sub(1,1) == '#' then
		elseif string.find(line, "127.0.0.1", 0, true) then
		elseif string.find(line, "255.255.255.255", 0, true) then
		elseif string.find(line, "::1", 0, true) then
		else
			return false
		end
	end
	return true
end

return check