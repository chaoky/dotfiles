set fish_greeting
bass source ~/.profile

#bitwarden
#set -x BW_SESSION MIMuQxznDg9mi6mv7YCw2Gx+SlVQkRKpMbYVV8uihPr6mnBVM0D7XelWbFjUnOjOKUo40YkSqqs3vdABiU/csw==
#set -x SSH (bw get password ssh)

setxkbmap -model pc104 -layout us -variant colemak

#set -Ua ~/.cargo/bin ~/ ~/Android/Sdk
set -U EDITOR emacsclient
set -U ANDROID_SDK ~/Android/Sdk

alias ls='ls --color=auto'
alias docker='sudo docker'
alias yk='xsel --clipboard --input'
alias pp='xsel --clipboard --output'

function e
    emacsclient -n $argv || emacs $argv
end


# if not set -q TMUX
#     tmux a || tmux
# end

starship init fish | source
direnv hook fish | source
