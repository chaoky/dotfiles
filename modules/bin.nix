{
  flake.nixosModules.bin = { pkgs, ... }:
    {
      home-manager.users.leo.home.packages = with pkgs; with nodePackages; [
        editorconfig-core-c bc jq gh helix gnutls binutils unzip fd
        (ripgrep.override { withPCRE2 = true; }) texlive.combined.scheme-medium
        pandoc fzf bat socat coreutils wakatime-cli tldr cmake gcc python3 tree-sitter
        lazygit cargo lua lua51Packages.luarocks-nix deno dasel prettierd
        stylua lsof openjdk sbt trashy tmux tmuxPlugins.dracula koka
        nixd lua-language-server vtsls vscode-langservers-extracted yaml-language-server
        vscode-js-debug terraform-ls harper dockerfile-language-server purescript basedpyright
        purescript-language-server ffmpeg yt-dlp ruff rust-analyzer unrar psmisc gnumake
        nix-tree claude-code github-cli jj-fzf jjui piper corepack
      ];
    };
}
