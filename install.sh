#!/bin/sh

[ -d "$HOME/.hammerspoon/Spoons" ] || mkdir $HOME/.hammerspoon/Spoons
[ -d "$HOME/.hammerspoon/Spoons/DumbIdiot.spoon" ] || mkdir $HOME/.hammerspoon/Spoons/DumbIdiot.spoon

cp -r dumbidiot.conf checks $HOME/.hammerspoon
if [ $? -eq 0 ]; then
    echo Config and checks installed
else
    echo FAIL
fi

cp -r init.lua bender.png $HOME/.hammerspoon/Spoons/DumbIdiot.spoon/
if [ $? -eq 0 ]; then
    echo Spoon installed
else
    echo FAIL
fi

# [ -f "$HOME/.hammerspoon/init.lua" ] || touch $HOME/.hammerspoon/init.lua
# echo "" >> $HOME/.hammerspoon/init.lua
# echo "-----------" >> $HOME/.hammerspoon/init.lua
# echo "--DumbIdiot" >> $HOME/.hammerspoon/init.lua
# echo "-----------" >> $HOME/.hammerspoon/init.lua
# echo 'hs.loadSpoon("DumbIdiot")' >> $HOME/.hammerspoon/init.lua
# echo 'spoon.DumbIdiot:bindHotKeys({runChecks = {{"ctrl", "alt", "cmd"}, "c"}})' >> $HOME/.hammerspoon/init.lua
# echo "" >> $HOME/.hammerspoon/init.lua