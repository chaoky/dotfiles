#!/usr/bin/env fish
set fish_greeting

# alias kc '/usr/bin/keychain -q --nogui $HOME/.ssh/id_rsa && source $HOME/.keychain/stanbot-15-fish'
alias ls 'ls --color=auto'
alias yk 'xsel --clipboard --input'
alias pp 'xsel --clipboard --output'
alias dps 'docker ps --format "table{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dbr 'docker run --rm -it $(docker build -q .)'
alias hm 'home-manager switch --flake ~/dotfiles/home-manager/#chaoky'

function ns
  if test ! -e ./.envrc
    echo "use nix" > .envrc
    direnv allow
  end
  if test ! -e shell.nix && test ! -e default.nix
    echo "with import <nixpkgs> {};
    mkShell {
        nativeBuildInputs = [
            pkg-config
            openssl
            fontconfig
            pcre2
        ];
    }" > shell.nix
    emacsclient shell.nix
  end
end

starship init fish | source
direnv hook fish | source
fish_add_path /home/linuxbrew/.linuxbrew/bin
fish_add_path /home/.cargo/bin


if [ "$INSIDE_EMACS" = vterm ]
    source $EMACS_VTERM_PATH/etc/emacs-vterm.fish
end
