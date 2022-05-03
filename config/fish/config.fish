set fish_greeting
# bass source ~/.profile

# setxkbmap -model pc104 -layout us -variant colemak

alias tablet '/home/lordie/Android/Sdk/emulator/emulator @tablet'
alias ls 'ls --color=auto'
alias docker 'sudo docker'
alias yk 'xsel --clipboard --input'
alias pp 'xsel --clipboard --output'

alias kc '/usr/bin/keychain -q --nogui $HOME/.ssh/id_rsa && source $HOME/.keychain/stanbot-15-fish'

starship init fish | source
direnv hook fish | source
