# DumbIdiot
Your best is still an idiot.

Dumb Idiot is a Hammerspoon Spoon port of snare's idiot (https://github.com/snare/idiot) MacOS tool for reminding you not to be stupid. 

The tool is mostly designed for people who harden their devices but sometimes poke holes in their hardening for a quick test and then forget to turn them back on. 

Dumb Idiot by default runs its checks every 30 minutes and warns you if any of them fail. The warnings include both a notification and changing the menubar icon, which if clicked will give you a list of the failed checks. 

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
11. Clear pasteboard periodically
12. File sharing
13. Check for static IPs on all network services

# Installation

First you need Hammerspoon (https://www.hammerspoon.org/).

Then just drop the unzipped release (DumbIdiot.spoon) in the ~/.hammerspoon/Spoons folder.

Finally, edit your init.lua in ~/.hammerspoon to include the following two lines to start using DumbIdiot:
```lua 
hs.loadSpoon("DumbIdiot")
spoon.DumbIdiot:bindHotKeys({runChecks = {{"ctrl", "alt", "cmd"}, "c"}})
```

This will load Dumb Idiot and set the hotkey ```⌃ + ⌥ + ⌘ + c``` to manually run all checks. 