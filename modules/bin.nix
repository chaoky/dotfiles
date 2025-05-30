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
    editorconfig-core-c bc jq gh neovim helix gnutls binutils unzip coreutils fd
    (ripgrep.override { withPCRE2 = true; }) texlive.combined.scheme-medium
    pandoc fzf bat socat (aspellWithDicts ( ds: with ds; [ en en-computers en-science ]))
    wakatime tldr cmake gcc python3 tree-sitter lazygit nodejs cargo direnv trashy
    lua lua51Packages.luarocks-nix deno dasel pnpm prettierd stylua lsof openjdk sbt unison-ucm
    tmux tmuxPlugins.dracula koka nixd lua-language-server rust-analyzer vtsls vscode-langservers-extracted
    yaml-language-server vscode-js-debug terraform-ls harper dockerfile-language-server-nodejs purescript
    purescript-language-server ffmpeg xsel xclip yt-dlp
  ];
  gui = [
    krita gimp3 inkscape blender libreoffice-fresh fontforge-gtk tiled ldtk obs-studio
    mongodb-compass dbeaver-bin redisinsight discord slack gnome-tweaks caffeine-ng ghostty
    zen-browser.default firefox-devedition-bin stremio qbittorrent vlc bruno vscode
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
