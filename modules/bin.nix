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
  nvr = writeShellScriptBin "nvr" ''
    nvim --server $NVIM --remote-tab $(realpath $1)
  '';
in
{
  options.local.bin = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable bin module";
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.leo.home.packages = [
      editorconfig-core-c bc jq gh helix gnutls binutils unzip fd 
      (ripgrep.override { withPCRE2 = true; }) texlive.combined.scheme-medium
      pandoc fzf bat socat coreutils wakatime-cli tldr cmake gcc python3 tree-sitter
      lazygit nodejs cargo direnv lua lua51Packages.luarocks-nix deno dasel pnpm 
      prettierd stylua lsof openjdk sbt trashy wezterm tmux tmuxPlugins.dracula koka
      nixd lua-language-server vtsls vscode-langservers-extracted yaml-language-server
      vscode-js-debug terraform-ls harper dockerfile-language-server purescript basedpyright 
      purescript-language-server ffmpeg yt-dlp ruff rust-analyzer unrar psmisc gnumake nvr 
      nix-tree redisinsight discord slack caffeine-ng qbittorrent vlc chromium firefox-devedition 
      insomnia brave mongodb-compass dbeaver-bin postman code-cursor spotify gnome-frog
    ];
  };
}
