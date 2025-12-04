{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs;
with nodePackages;
with lib;
let
  cfg = config.local.bin;
  nvr = pkgs.writeShellScriptBin "nvr" ''
    nvim --server $NVIM --remote-tab $(realpath $1)
  '';
  core = [
    editorconfig-core-c bc jq gh helix gnutls binutils
    unzip fd (ripgrep.override { withPCRE2 = true; }) texlive.combined.scheme-medium
    pandoc fzf bat socat coreutils wakatime-cli tldr 
    cmake gcc python3 tree-sitter lazygit nodejs cargo
    direnv lua lua51Packages.luarocks-nix deno dasel pnpm prettierd 
    stylua lsof openjdk sbt trashy
    tmux tmuxPlugins.dracula koka nixd lua-language-server  vtsls
    vscode-langservers-extracted yaml-language-server vscode-js-debug
    terraform-ls harper dockerfile-language-server purescript
    purescript-language-server ffmpeg xsel xclip yt-dlp ruff
    basedpyright rust-analyzer unrar psmisc gnumake nvr alsa-utils helvum
    nix-tree
  ];
  gui = [
    redisinsight discord slack gnome-tweaks caffeine-ng ghostty
    qbittorrent vlc chromium firefox-devedition insomnia brave
    mongodb-compass dbeaver-bin postman code-cursor spotify gnome-frog
  ];
  games = [
    gdlauncher-carbon lutris wineWowPackages.stable winetricks wine-wayland
    krita gimp3 inkscape blender libreoffice-fresh fontforge-gtk
    tiled ldtk aseprite ryubing
  ];
in
{
  options.local.bin = {
    enable = mkEnableOption "bin module";
    gui = mkEnableOption "gui packages";
    games = mkEnableOption "game packages";
  };
  config = mkIf cfg.enable {
    home.packages = mkMerge [
      core
      (mkIf (cfg.gui) gui)
      (mkIf (cfg.games) games)
    ];
  };
}
