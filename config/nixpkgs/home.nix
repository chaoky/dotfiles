{ config, pkgs, ... }:

let
  emacspackages = with pkgs; [
    ((emacsPackagesFor emacsUnstable).emacsWithPackages(epkgs: with epkgs; [ vterm ]))
    pinentry_emacs
    # :checkers spell
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    # :tools editorconfig
    editorconfig-core-c # per-project style config
    # :tools lookup & :lang org +roam
    sqlite
    # :lang latex & :lang org (latex previews)
    texlive.combined.scheme-medium
    # :lang beancount
    beancount
  ];

  packages = with pkgs; [
    binutils
    coreutils
    git
    (ripgrep.override {withPCRE2 = true;})
    gnutls
    imagemagick
    zstd
    fava
    starship
    iosevka-bin
    cmake
    wakatime
    tldr
    fzf
    discord
    rust-analyzer
    nil
    metals
    deno
    mongodb-compass
    dbeaver
    furtherance
    beekeeper-studio
    firefox
    nodejs
    socat
    starship
    python3
    bat
    fd
    fontforge-gtk
    rustup
  ];

  nodePackages = with pkgs.nodePackages; [
    typescript-language-server
    typescript
    pnpm
    prettier
    yaml-language-server
    vscode-langservers-extracted
    bash-language-server
    dockerfile-language-server-nodejs
  ];

  pythonPackages = with pkgs.python3Packages; [
    setuptools
  ];

  activityWatch = pkgs.callPackage /home/lordie/Projects/nixpkgs/pkgs/applications/misc/activitywatch { };
in
{
  home.username = "lordie";
  home.homeDirectory = "/home/lordie";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;
  programs.bash.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  home.sessionVariables = {
    XDG_DATA_DIRS = "$HOME/.home-manager-share:$XDG_DATA_DIRS";
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "autopair";
        src = pkgs.fetchFromGitHub {
         owner = "jorgebucaran";
         repo = "autopair.fish";
         rev = "1.0.4";
         hash = "sha256-s1o188TlwpUQEN3X5MxUlD/2CFCpEkWu83U9O+wg3VU=";
        };
      }
      {
        name = "replay";
        src = pkgs.fetchFromGitHub {
         owner = "jorgebucaran";
         repo = "replay.fish";
         rev = "1.2.1";
         hash = "sha256-bM6+oAd/HXaVgpJMut8bwqO54Le33hwO9qet9paK1kY=";
        };
      }
      {
        name = "nix-env";
        src = pkgs.fetchFromGitHub {
         owner = "lilyball";
         repo = "nix-env.fish";
         rev = "master";
         hash = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      }
    ];
    interactiveShellInit = builtins.readFile ./config.fish;
  };

  home.activation = {
    linkDesktopApplications = {
      after = [ "writeBoundary" "createXdgUserDirectories" ];
      before = [ ];
      data = ''
        rm -rf $HOME/.home-manager-share
        mkdir -p $HOME/.home-manager-share
        cp -Lr --no-preserve=mode,ownership ${config.home.homeDirectory}/.nix-profile/share/* $HOME/.home-manager-share
      '';
    };
  };

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];

  home.packages = packages ++ nodePackages ++ emacspackages ++ pythonPackages ++ [activityWatch];
}
