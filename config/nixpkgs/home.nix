{ config, pkgs, ... }:

let
  packages = with pkgs; [
    ((emacsPackagesFor emacsUnstable).emacsWithPackages(epkgs: with epkgs; [ vterm ]))
    #core doom deps
    (ripgrep.override {withPCRE2 = true;})
    gnutls
    #Optional dependencies
    fd
    imagemagick
    zstd
    fava
    pinentry_emacs
    # :checkers spell
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    # :tools editorconfig
    editorconfig-core-c
    # :tools lookup & :lang org +roam
    sqlite
    # :lang latex & :lang org (latex previews)
    texlive.combined.scheme-medium
    # :lang beancount
    beancount
    #fonts
    emacs-all-the-icons-fonts
    iosevka-bin
    #dev deps
    git
    binutils
    coreutils
    cmake
    wakatime
    tldr
    starship
    fzf
    rust-analyzer
    metals
    deno
    mongodb-compass
    nil
    dbeaver
    beekeeper-studio
    nodejs
    socat
    python3
    bat
    rustup
    #other
    discord
    furtherance
    firefox
    fontforge-gtk
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
  localPackages = [
    activityWatch
  ];

in
{
  home.username = "lordie";
  home.homeDirectory = "/home/lordie";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;
  programs.bash.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  home.packages = packages ++ nodePackages ++ pythonPackages ++ localPackages;
  fonts.fontconfig.enable = true;

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
        for f in applications mime icons sounds; do
          mkdir -p $HOME/.local/share/$f
          cp -ans --no-preserve=mode,ownership ${config.home.homeDirectory}/.nix-profile/share/$f/* $HOME/.local/share/$f
        done
      '';
    };
  };

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
    }))
  ];
}
