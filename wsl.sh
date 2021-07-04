#!/usr/bin/env bash
wsl.exe --system -e bash -c "echo -e '\n[keyboard]\nkeymap_layout=us\nkeymap_variant=colemak\n' >> /home/wslg/.config/weston.ini && pkill -HUP weston"
emacs --daemon
