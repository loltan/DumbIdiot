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

# Features
- Periodic checks: By default Dumb Idiot runs its set of checks every 30 minutes.
- Notifications: Dumb Idiot will send a persistent notification (until dismissed or snoozed) to the Notification Center. Clicking on the body or the snooze button will disable notifications until the issues are resolved.
- Menubar icon: If everything is going well, the menubar will have a cool guy emoji, but if issues are found, an ambulance will arrive. Clicking on the ambulance tells you which checks failed via the drop down menu items.
- Read-only, low privileged user checks: all checks are read-only using low-privileged access (no root or sudo)
- Hot keys: Optionally a MacOS global key combination can be set to run the checks manually (see instructions below)

# Installation
First you need Hammerspoon (https://www.hammerspoon.org/).

Then just drop the unzipped release (DumbIdiot.spoon) in the ~/.hammerspoon/Spoons folder.

Finally, edit your init.lua in ~/.hammerspoon (create it if it doesn't exist) to include the following two lines to start using Dumb Idiot:
```lua 
hs.loadSpoon("DumbIdiot")
spoon.DumbIdiot:bindHotKeys({runChecks = {{"ctrl", "alt", "cmd"}, "c"}})
```

This will load Dumb Idiot and set the hotkey ```⌃ + ⌥ + ⌘ + c``` to manually run all checks. 

To get the full value of Dumb Idiot notifications set Hammerspoon's notification style to 'Alerts' in System Preferences -> Notifications -> Hammerspoon

# Planned checks and features
- TCC settings
- VPN check
- More modular checks (each check will be its own file)
- Config file instead of global variables
- Bugfixes