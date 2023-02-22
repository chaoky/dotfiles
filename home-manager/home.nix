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
    nil
    nodejs
    socat
    python3
    bat
    rustup
    devbox
    #ui
    mongodb-compass
    dbeaver
    fontforge-gtk
    discord
    beekeeper-studio
    firefox-devedition-bin
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

  gnomePackages = with pkgs.gnomeExtensions; [
    pano
    monitor-window-switcher-2
    appindicator
  ];

  activityWatch = pkgs.callPackage ./local/activitywatch.nix { };
  localPackages = [
    activityWatch
  ];

in
{
  fonts.fontconfig.enable = true;
  targets.genericLinux.enable = true;
  home = {
    username = "lordie";
    homeDirectory = "/home/lordie";
    stateVersion = "22.11";
    packages =
      packages
      ++ nodePackages
      ++ pythonPackages
      ++ localPackages
      ++ gnomePackages;
    activation = {
      linkDesktopApplications = {
        after = [ "writeBoundary" "createXdgUserDirectories" ];
        before = [ ];
        data = "/usr/bin/update-desktop-database";
      };
    };
  };

  dconf.settings = {
    "org/gnome/shell".enabled-extensions =
      (map (extension: extension.extensionUuid) gnomePackages)
      #NOTE popos only
      #NOTE requires enabling the extension by hand once
      ++ ["system76-power@system76.com"];
  };

  programs = {
    home-manager.enable = true;
    bash.enable = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit  = builtins.readFile ./config.fish;
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
  };

  programs.git = {
    enable = true;
    userEmail = "levimanga@gmail.com";
    userName = "chaoky";
  };
}
