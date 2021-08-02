local check = {}

function check.runCheck()
	happy = true
	offendingNetworkServices = {}
	res = hs.execute("networksetup -listallnetworkservices")
	networkServices = split(res, "\n")

	for service = 2, #networkServices-1 do
		proxySettings = hs.execute("networksetup -getinfo \"" .. networkServices[service] .. "\" | grep \"Manual Configuration\"")
		if #proxySettings ~= 0 then
			happy = false
			table.insert(offendingNetworkServices, networkServices[service])
		end
	end

	if happy then
		return true
	else
		return false, "‼️ System-wide web proxy is on"
	end
end

function split(s, delimiter)
    result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

return check