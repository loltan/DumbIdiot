local check = {}

function check.runCheck()
    _, result = hs.execute("softwareupdate -l | grep -i security")
    if result then 
        return false, "‼️ Security updates are available"
    else
        return true
    end
end

return check