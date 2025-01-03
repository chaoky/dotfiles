#!/usr/bin/env fish

#git clone --depth 1 https://github.com/AstroNvim/AstroNvim ~/.config/nvim &
#git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs &

for file in (find $HOME -maxdepth 2 -lname '*dotfiles*')
    unlink $file
end

for file in config/* home/*
    set source_path (realpath $file)
    set target_path $HOME/.(string replace home/ '' $file)

    #backup if already exists
    if test -d $target_path
        mv $target_path $target_path:backup
    end

    ln -sv $source_path $target_path
end

chmod 600 $HOME/.ssh/id_rsa
git remote set-url origin git@github.com:chaoky/dotfiles.git

if ! test -f ~/.wakatime.cfg
    cp wakatime.cfg ~/.wakatime.cfg
end

git config --global user.name chaoky
git config --global user.email "levimanga@gmail.com"

sudo usermod -aG docker $USER

#home-manager switch --flake ~/dotfiles/home-manager/#chaoky
