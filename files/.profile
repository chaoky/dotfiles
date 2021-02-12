export PATH="~/.cargo/bin:$PATH"
export DISPLAY=:0
export LIBGL_ALWAYS_INDIRECT=1
export EDITOR=emacsclient

if ! pgrep wsld >>/dev/null 2>&1; then
	nohup wsld >/dev/null </dev/null 2>&1 &
	disown

	# sleep until $DISPLAY is up
	while ! xset q >/dev/null 2>&1; do
		sleep 0.3
	done
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
if [ -e /home/lordie/.nix-profile/etc/profile.d/nix.sh ]; then . /home/lordie/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
