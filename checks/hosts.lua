local check = {}

function check.runCheck(configAllow)
	clean = true
	
	-- LiamO: can't believe LUA doesn't have a "continue" control flow
	for line in io.lines("/etc/hosts") do
		if not isempty(line) then 
			clean = false
			for i=1, #configAllow do
				-- print("Checking for " .. configAllow[i] .. " in: " .. line)
				if line:sub(1,1) == '#' then 
					-- print("found # in " .. line)
					clean = true
					goto continue
				elseif string.find(line, configAllow[i]) then 
					-- print("found "..configAllow[i].." in " .. line)
					clean = true 
					goto continue
				end
			end	
		else 
			print("line is empty: " .. line)
			clean = true
		end
		::continue::
		if not clean then
			-- print("Did not find allowlist item in: " .. line)
			return false, "‼️ Hosts file modified"
		end
	end
	return true
end

function isempty(s)
	return s == nil or s == ''
end

return check