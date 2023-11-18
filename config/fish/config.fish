#!/usr/bin/env fish
set fish_greeting

# alias kc '/usr/bin/keychain -q --nogui $HOME/.ssh/id_rsa && source $HOME/.keychain/stanbot-15-fish'
alias ls 'ls --color=auto'
alias yk 'xsel --clipboard --input'
alias pp 'xsel --clipboard --output'
alias dps 'docker ps --format "table{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dbr 'docker run --rm -it $(docker build -q .)'
alias hm 'home-manager switch --flake ~/dotfiles/home-manager/#chaoky'


set -x SSH_AUTH_SOCK $XDG_RUNTIME_DIR/gcr/ssh
set -x DISPLAY :1.0
set -x GDK_BACKEND x11
set -x ANDROID_HOME /mnt/d/Android
set -x ANDROID_SDK_ROOT /mnt/d/Android

fish_add_path /home/linuxbrew/.linuxbrew/bin
fish_add_path ~/.cargo/bin

set PNPM_HOME "/home/chaoky/.local/share/pnpm"
fish_add_path /home/chaoky/.local/share/pnpm

set BUN_INSTALL ~/.bun
fish_add_path ~/.bun/bin

if [ "$INSIDE_EMACS" = vterm ]
    source $EMACS_VTERM_PATH/etc/emacs-vterm.fish
end

starship init fish | source
direnv hook fish | source

# pnpm
set -gx PNPM_HOME "/home/chaoky/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end