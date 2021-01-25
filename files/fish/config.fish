set fish_greeting

#wsl display
# set -x DISPLAY (grep -Po '(?<=nameserver ).*' /etc/resolv.conf):0
# set -x LIBGL_ALWAYS_INDIRECT 1

#bitwarden
set -x BW_SESSION MIMuQxznDg9mi6mv7YCw2Gx+SlVQkRKpMbYVV8uihPr6mnBVM0D7XelWbFjUnOjOKUo40YkSqqs3vdABiU/csw==
set -x SSH (bw get password ssh)

set -x EDITOR emacsclient

setxkbmap -model pc104 -layout us -variant colemak

alias ls='ls --color=auto'
alias docker='sudo docker'
alias yk='xsel --clipboard --input'
alias pp='xsel --clipboard --output'
bass source ~/.profile


function e
    emacsclient -n $argv || emacs $argv
end


# if not set -q TMUX
#     tmux a || tmux
# end

starship init fish | source
direnv hook fish | source
