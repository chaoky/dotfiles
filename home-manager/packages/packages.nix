{ pkgs }:

{
  system = with pkgs; [
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

  gnome = with pkgs.gnomeExtensions; [
    pano
    monitor-window-switcher-2
    appindicator
  ];

  local = with pkgs; [
    (callPackage ./activitywatch.nix { })
  ];
}
