set fish_greeting
#bass source ~/.profile

#bitwarden
#set -x BW_SESSION MIMuQxznDg9mi6mv7YCw2Gx+SlVQkRKpMbYVV8uihPr6mnBVM0D7XelWbFjUnOjOKUo40YkSqqs3vdABiU/csw==
#set -x SSH (bw get password ssh)

# function e
#     emacsclient -n $argv || emacs $argv
# end

alias tablet '/home/lordie/Android/Sdk/emulator/emulator @tablet'
alias ls 'ls --color=auto'
alias docker 'sudo docker'
alias yk 'xsel --clipboard --input'
alias pp 'xsel --clipboard --output'

starship init fish | source
direnv hook fish | source

# if not set -q TMUX
#     tmux a || tmux
# end

#set -Ua ~/.cargo/bin ~/ ~/Android/Sdk
#set -U EDITOR e
#set -U ANDROID_SDK ~/Android/Sdk
