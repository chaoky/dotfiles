{ pkgs }:
with pkgs;
{
  system = [
    gnutls
    binutils
    unzip
    coreutils
    fd
    (ripgrep.override {withPCRE2 = true;})
    starship
    fzf
    bat
    socat
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    (nerdfonts.override { fonts = [ "Iosevka" ]; })
    alacritty
  ];

  dev = [
    wakatime
    tldr
    cmake
    gcc
    python3
    tree-sitter 
    lazygit
    nodejs
    cargo
    neovim
  ];

  # emacs = [
  #   ((emacsPackagesFor emacsUnstable).emacsWithPackages(epkgs: with epkgs; [ vterm ]))
  #   imagemagick
  #   zstd
  #   fava
  #   editorconfig-core-c
  #   texlive.combined.scheme-medium
  #   pandoc
  #   emacs-all-the-icons-fonts
  #   sqlite
  # ];

  ui = [
    mongodb-compass
    dbeaver
    fontforge-gtk
    discord
    microsoft-edge
    firefox-devedition-bin
    stremio
  ];
}
