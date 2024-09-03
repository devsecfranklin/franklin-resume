# winetricks explorer
# run winecfg and set emulate virtual desktop

# Sound
winetricks sound=disabled # shut off sound
Revert it back using " winetricks sound=pulse " or "winetricks settings list"

winetricks dlls # install first one

# start a new game, shut off sound and graphics in the Game menu
