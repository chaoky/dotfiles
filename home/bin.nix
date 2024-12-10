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
  core = [
    helix
    gnutls
    binutils
    unzip
    coreutils
    fd
    (ripgrep.override { withPCRE2 = true; })
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
    wl-clipboard
    trashy
    lua
    lua51Packages.luarocks-nix
    deno
    dasel
  ];
  lsp = with pkgs.nodePackages; [
    typescript-language-server
    typescript
    pnpm
    prettier
    yaml-language-server
    vscode-langservers-extracted
    bash-language-server
    dockerfile-language-server-nodejs
    lua-language-server
    stylua
    nixfmt
    nil
    rust-analyzer
  ];
  extra = mkIf (!config.wsl) [
    mongodb-compass
    dbeaver-bin
    fontforge-gtk
    discord
    microsoft-edge
    firefox-devedition-bin
    stremio
    (nerdfonts.override {
      fonts = [
        "Iosevka"
        "NerdFontsSymbolsOnly"
      ];
    })
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
