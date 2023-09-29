#!/usr/bin/env fish
set fish_greeting

# alias kc '/usr/bin/keychain -q --nogui $HOME/.ssh/id_rsa && source $HOME/.keychain/stanbot-15-fish'
alias ls 'ls --color=auto'
alias yk 'xsel --clipboard --input'
alias pp 'xsel --clipboard --output'
alias dps 'docker ps --format "table{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dbr 'docker run --rm -it $(docker build -q .)'
alias hm 'home-manager switch --flake ~/dotfiles/home-manager/#chaoky'

set EDITOR emacsclient
set PNPM_HOME "/home/chaoky/.local/share/pnpm"
fish_add_path /home/chaoky/.local/share/pnpm

fish_add_path /home/linuxbrew/.linuxbrew/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.bun/bin

if [ "$INSIDE_EMACS" = vterm ]
    source $EMACS_VTERM_PATH/etc/emacs-vterm.fish
end

starship init fish | source
direnv hook fish | source
