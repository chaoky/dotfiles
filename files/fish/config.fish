# -*- mode: sh -*-
#wsl display
set -x DISPLAY (grep -Po '(?<=nameserver ).*' /etc/resolv.conf):0
set fish_greeting
setxkbmap -model pc104 -layout us -variant colemak

alias ls='ls --color=auto'
alias docker='sudo docker'
alias yk='xsel --clipboard --input'

starship init fish | source

# if not set -q TMUX
#     tmux a || tmux
# end

function e
    emacsclient -n $argv || emacs $argv
end
