#!/usr/bin/fish

for file in */*
    rm -r $HOME/.(string replace home/ '' $file)
    ln -sv (realpath $file) $HOME/.(string replace home/ '' $file)
end

chmod 600 $HOME/.ssh/id_rsa
# antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh
git config --global user.email "levimanga@gmail.com" && git config --global user.name "lordie"
git remote set-url origin git@github.com:chaoky/dotfiles.git
