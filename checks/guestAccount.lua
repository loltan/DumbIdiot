local check = {}

function check.runCheck()
	resultLogin = string.sub(hs.execute("defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled"), 1, 1)
	resultShareSMB = string.sub(hs.execute("defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server.plist AllowGuestAccess"), 1, 1)
	if ((resultLogin == "1") or (resultShareSMB == "1")) then
		return false, "‼️ Guest account is enabled"
	else
		return true
	end
end

return check