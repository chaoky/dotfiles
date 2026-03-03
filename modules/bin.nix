{
  flake.nixosModules.bin = { pkgs, ... }:
    let
      nvr = pkgs.writeShellScriptBin "nvr" ''
        nvim --server $NVIM --remote-tab $(realpath $1)
      '';
    in
    {
      home-manager.users.leo.home.packages = with pkgs; with nodePackages; [
        editorconfig-core-c bc jq gh helix gnutls binutils unzip fd
        (ripgrep.override { withPCRE2 = true; }) texlive.combined.scheme-medium
        pandoc fzf bat socat coreutils wakatime-cli tldr cmake gcc python3 tree-sitter
        lazygit nodejs cargo lua lua51Packages.luarocks-nix deno dasel pnpm
        prettierd stylua lsof openjdk sbt trashy tmux tmuxPlugins.dracula koka
        nixd lua-language-server vtsls vscode-langservers-extracted yaml-language-server
        vscode-js-debug terraform-ls harper dockerfile-language-server purescript basedpyright
        purescript-language-server ffmpeg yt-dlp ruff rust-analyzer unrar psmisc gnumake nvr
        nix-tree claude-code github-cli jj-fzf jjui piper
      ];
    };
}
