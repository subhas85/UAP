#!/bin/sh

# Write procedures here you want to execute on reconnect

# Release stuck modifier keys after RDP KeyboardSync PDU left them pressed.
# Mod3 (ISO_Level5_Shift) commonly gets stuck and breaks Alt+number bindings in i3.
if command -v xdotool >/dev/null 2>&1; then
    xdotool keyup shift ctrl alt super ISO_Level5_Shift ISO_Level3_Shift 2>/dev/null
fi
