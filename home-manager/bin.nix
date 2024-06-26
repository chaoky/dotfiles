{ config, lib, pkgs, ... }:
with pkgs;
with lib;
let
  cfg = config.local.bin;
  core = [
    gnutls
    binutils
    unzip
    coreutils
    fd
    (ripgrep.override { withPCRE2 = true; })
    fzf
    bat
    socat
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
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
  ];
  extra = mkIf (!config.wsl) [
    mongodb-compass
    dbeaver
    fontforge-gtk
    discord
    microsoft-edge
    firefox-devedition-bin
    stremio
    (nerdfonts.override { fonts = [ "Iosevka" ]; })
  ];
in
{
  options.local.bin = { enable = mkEnableOption "bin module"; };
  config = mkIf cfg.enable {
    home.packages = mkMerge [ core extra ];
  };
}
