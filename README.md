# Dumb Idiot
Your best is still an idiot.

Dumb Idiot is a Hammerspoon port of snare's idiot (https://github.com/snare/idiot) MacOS tool for reminding you not to be stupid with additional checks. 

The tool is mostly designed for people who harden their devices but sometimes poke holes in their hardening for a quick test and then forget to turn them back on. 

# Checks 
Currently the following checks are implemented:
1. Little Snitch
2. Apache
3. Docker
4. Firewall
5. SSH
6. SIP
7. FileVault
8. Guest account enabled
9. Screen sharing
10. System proxy
11. File sharing
12. Check for static IPs on all network services
13. TFTP check
14. /etc/resolver entry check
15. /etc/hosts entry check
16. macOS security updates pending (disabled by default as it adds a 10 second delay)

# Features
- Periodic checks: By default Dumb Idiot runs its set of checks every 30 minutes
- Notifications: Dumb Idiot will send a persistent notification (until dismissed or snoozed) to the Notification Center for each failed check. Clicking on the body or the snooze button will disable notifications for the particular problem until the issue is resolved
- Menubar icon: If everything is going well, the menubar will have a cool guy emoji, but if issues are found, an ambulance will arrive. Clicking on the ambulance tells you which checks failed via the drop down menu items
- Read-only, low privileged user checks: all checks are read-only using low-privileged access (no root or sudo)
- Hot keys: Optionally a MacOS global key combination can be set to run the checks manually (see instructions below)
- Modular design: Easy to add new checks (see below)
- Config file: all checks can be disabled/enabled in the config file among other settings

# Installation
1. First you need Hammerspoon (https://www.hammerspoon.org/).
2. Then just drop the unzipped release (DumbIdiot.spoon) in the ```~/.hammerspoon/Spoons``` folder.
3. Next, add the checks directory and the ```dumbidiot.conf``` to ```~/.hammerspoon```.
4. Finally, edit your ```init.lua``` in ```~/.hammerspoon``` (create it if it doesn't exist) to include the following two lines to start using Dumb Idiot:
    ```lua 
    hs.loadSpoon("DumbIdiot")
    spoon.DumbIdiot:bindHotKeys({runChecks = {{"ctrl", "alt", "cmd"}, "c"}})
    ```
    This will load Dumb Idiot and set the hotkey ```⌃ + ⌥ + ⌘ + c``` to manually run all checks. 

To get the full value of Dumb Idiot notifications, set Hammerspoon's notification style to 'Alerts' in System Preferences -> Notifications -> Hammerspoon

# Configuration file
```dumbidiot.conf``` is the configuration file which controls all settings and checks for Dumb Idiot.

## General settings
### menubarAlwaysShow
Controls whether the cool guy emoji is shown. If set to ```false``` only the ambulance icon will show up when a check fails but otherwise Dumb Idiot will be running in stealth mode. 

### startEnabled
If set to false, Dumb Idiot will not perform checks periodically. Pressing the chosen hotkey combination still runs the checks however. 

### checkTimer
The time interval when the enabled checks are run in the background, in minutes.

## Checks

### enabled
Controls whether the check is run either automatically or when the hotkeys are pressed.

### snoozed
A required attribute for new checks, however it should be set to ```false```. This controls the notifications dynamically while Dumb Idiot is running.

# Adding your own check
Each check is its own file. If you want to add a new one, just create a new .lua file using the following template and put it next to the other checks in the ```checks``` folder:

``` lua
local check = {}

function check.runCheck()
    -- YOUR CODE COMES HERE --
    if checkPasses then
        -- Your check needs to return true if it passes
        return true
        -- or false and an error string that will show up with the ambulance
        return false, "‼️ XYZ check failed"
    end
end

return check
```

Next, add a line to the checks table in ```dumbidiot.conf``` such as:
``` lua
checks = {
    { name = "yourChecksNameInCamelCase", enabled = true, snoozed = false },
}
```

It's important that the .lua file's name and the new check line in the config are the same.

The snoozed attribute should be false by default, it's an internal variable for notifications, dynamically updated by Dumb Idiot when needed.

Finally, just reload your Hammerspoon config and you should be good to go.

# Planned checks and features
- TCC settings
- VPN check
- Bugfixes
