local check = {}

function check.runCheck()
    _, result = hs.execute("ps aux | grep httpd | grep -v grep")
    if result then 
        return false, "‼️ Apache is running"
    else
        return true
    end
end

return check