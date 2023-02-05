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
    fish
    starship
    direnv
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
  ];

  nodePackages = with pkgs.nodePackages; [
    typescript-language-server
    typescript
    pnpm
    prettier
    yaml-language-server
    vscode-langservers-extracted
    bash-language-server
  ];

  activityWatch = pkgs.callPackage /home/lordie/Projects/nixpkgs/pkgs/applications/misc/activitywatch { };
in
{
  home.username = "lordie";
  home.homeDirectory = "/home/lordie";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  programs.bash = {
	  enable = true;
    profileExtra = ''
      export XDG_DATA_DIRS=$HOME/.home-manager-share:$XDG_DATA_DIRS
    '';
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "bass";
        src = pkgs.fetchFromGitHub {
         owner = "edc";
         repo = "bass";
         rev = "v1.0";
         hash = "sha256-XpB8u2CcX7jkd+FT3AYJtGwBtmNcLXtfMyT/z7gfyQw=";
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

  home.packages = packages ++ nodePackages ++ emacspackages ++ [activityWatch];
}
