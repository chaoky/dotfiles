set fish_greeting

# alias kc '/usr/bin/keychain -q --nogui $HOME/.ssh/id_rsa && source $HOME/.keychain/stanbot-15-fish'

alias ls 'ls --color=auto'
alias yk 'xsel --clipboard --input'
alias pp 'xsel --clipboard --output'

starship init fish | source
direnv hook fish | source

if [ "$INSIDE_EMACS" = vterm ]
    source $EMACS_VTERM_PATH/etc/emacs-vterm.fish
end
