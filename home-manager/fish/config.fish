#!/usr/bin/env fish
set fish_greeting
if [ "$INSIDE_EMACS" = vterm ]
    source $EMACS_VTERM_PATH/etc/emacs-vterm.fish
end

fish_add_path ~/.cargo/bin

set PNPM_HOME "/home/chaoky/.local/share/pnpm"
fish_add_path "$PNPM_HOME"

set BUN_INSTALL ~/.bun
fish_add_path ~/.bun/bin

-set -gx PAGER cat
# set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh
# set -gx DISPLAY :1.0
# set -gx GDK_BACKEND x11

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

jump shell fish | source
starship init fish | source
direnv hook fish | source
