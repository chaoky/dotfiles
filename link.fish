#!/usr/bin/env fish

for file in (find $HOME -maxdepth 2 -lname '*dotfiles*')
    unlink $file
end

for file in config/* home/*
    ln -svb (realpath $file) $HOME/.(string replace home/ '' $file)
end

chmod 600 $HOME/.ssh/id_rsa
git remote set-url origin git@github.com:chaoky/dotfiles.git
home-manager switch --flake ~/dotfiles/home-manager/#chaoky
