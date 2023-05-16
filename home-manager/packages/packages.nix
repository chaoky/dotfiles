{ pkgs }:

{
  system = with pkgs; [
    wakatime
    tldr
    starship
    fzf
    bat
  ];

  emacs = with pkgs; [
    ((emacsPackagesFor emacsUnstable).emacsWithPackages(epkgs: with epkgs; [ vterm ]))
    #core
    (ripgrep.override {withPCRE2 = true;})
    gnutls
    fd
    imagemagick
    zstd
    fava
    pinentry_emacs
    # :tools editorconfig
    editorconfig-core-c
    # :checkers spell
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    # :lang latex & :lang org (latex previews)
    texlive.combined.scheme-medium
    # :lang markdown
    pandoc
    #fonts
    emacs-all-the-icons-fonts
    iosevka-bin
  ];

  dev = with pkgs; [
    binutils
    coreutils
    sqlite
    cmake
    rust-analyzer
    metals
    deno
    nil
    nodejs
    socat
    python3
    rustup
    nixfmt
  ];

  ui = with pkgs; [
    mongodb-compass
    dbeaver
    fontforge-gtk
    discord
    beekeeper-studio
    firefox-devedition-bin
  ];

  node = with pkgs.nodePackages; [
    typescript-language-server
    typescript
    pnpm
    prettier
    yaml-language-server
    vscode-langservers-extracted
    bash-language-server
    dockerfile-language-server-nodejs
  ];

  python = with pkgs.python3Packages; [
    setuptools
  ];

  local = with pkgs; [
    (callPackage ./activitywatch.nix { })
  ];
}
