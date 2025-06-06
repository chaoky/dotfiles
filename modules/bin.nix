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
  core = [
    editorconfig-core-c bc jq gh helix gnutls binutils
    unzip fd (ripgrep.override { withPCRE2 = true; }) texlive.combined.scheme-medium
    pandoc fzf bat socat coreutils wakatime tldr 
    (aspellWithDicts ( ds: with ds; [ en en-computers en-science ])) cmake gcc 
    python3 tree-sitter lazygit nodejs cargo direnv 
    lua lua51Packages.luarocks-nix deno dasel pnpm prettierd 
    stylua lsof openjdk sbt unison-ucm trashy
    tmux tmuxPlugins.dracula koka nixd lua-language-server  vtsls
    vscode-langservers-extracted yaml-language-server vscode-js-debug
    terraform-ls harper dockerfile-language-server-nodejs purescript
    purescript-language-server ffmpeg xsel xclip yt-dlp ruff
    basedpyright rust-analyzer
  ];
  gui = [
    krita gimp3 inkscape blender libreoffice-fresh fontforge-gtk 
    tiled ldtk obs-studio mongodb-compass dbeaver-bin
    redisinsight discord slack gnome-tweaks caffeine-ng ghostty
    zen-browser.default stremio qbittorrent vlc bruno vscode
    zed-editor chromium via
  ];
  games = [
    gdlauncher-carbon lutris wineWowPackages.stable winetricks wineWayland
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
