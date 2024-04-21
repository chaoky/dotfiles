#!/usr/bin/env fish

if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish' ]
  source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
end

if [ "$INSIDE_EMACS" = vterm ]
    source $EMACS_VTERM_PATH/etc/emacs-vterm.fish
end

fish_add_path ~/.cargo/bin

set PNPM_HOME "/home/chaoky/.local/share/pnpm"
fish_add_path "$PNPM_HOME"

set BUN_INSTALL ~/.bun
fish_add_path ~/.bun/bin

set fish_greeting
set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh
set -gx PAGER cat
# set -x DISPLAY :1.0
# set -x GDK_BACKEND x11

alias ls 'ls --color=auto'
alias dps 'docker ps --format "table{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dbr 'docker run --rm -it (docker build -q .)'
#alias hm 'home-manager switch --flake ~/dotfiles/home-manager/#chaoky'

jump shell fish | source
starship init fish | source
direnv hook fish | source
