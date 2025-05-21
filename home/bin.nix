{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs;
with lib;
let
  cfg = config.local.bin;
  mediatoascii = pkgs.callPackage ../pkg/media-to-ascii.nix {};
  core = [
    mediatoascii 
    imagemagick
    editorconfig-core-c
    bc
    jq
    gh
    helix
    gnutls
    binutils
    unzip
    coreutils
    fd
    (ripgrep.override { withPCRE2 = true; })
    texlive.combined.scheme-medium
    pandoc
    fzf
    bat
    socat
    (aspellWithDicts (
      ds: with ds; [
        en
        en-computers
        en-science
      ]
    ))
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
    direnv
    trashy
    lua
    lua51Packages.luarocks-nix
    deno
    dasel
    pnpm
    prettierd
    stylua
    lsof
    openjdk
    sbt
    unison-ucm
    tmux
    tmuxPlugins.dracula
  ];
  lsp = with pkgs.nodePackages; [
    koka
    nixd
    lua-language-server
    rust-analyzer
    vtsls
    vscode-langservers-extracted
    yaml-language-server
    terraform-ls
    harper
    dockerfile-language-server-nodejs
    purescript
    purescript-language-server
  ];
  extra = mkIf (!config.wsl) [
    gdlauncher-carbon
    prismlauncher
    gimp3
    blender
    inkscape
    krita
    libreoffice-fresh
    scribus
    mongodb-compass
    dbeaver-bin
    fontforge-gtk
    discord
    microsoft-edge
    firefox-devedition-bin
    stremio
    nerd-fonts.iosevka
    nerd-fonts.symbols-only
    gnome-tweaks
    caffeine-ng
    slack
    zen-browser.default
    alacritty
    ghostty
    vscode
    lutris
    wineWowPackages.stable
    winetricks
    wineWayland
    redisinsight
    kitty
    easyeffects
    yt-dlp
    rhythmbox
    lollypop
    ffmpeg
    xsel
    xclip
    qbittorrent
    vlc
    bruno
    tiled
    ldtk
  ];
in
{
  options.local.bin = {
    enable = mkEnableOption "bin module";
  };
  config = mkIf cfg.enable {
    home.packages = mkMerge [
      core
      extra
      lsp
    ];
  };
}
