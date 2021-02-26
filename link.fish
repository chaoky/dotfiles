#!/usr/bin/fish

for file in */*
    rm -r $HOME/.(string replace home/ '' $file)
    ln -sv (realpath $file) $HOME/.(string replace home/ '' $file)
end
