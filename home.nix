# Standalone home-manager configuration (e.g., for WSL or non-NixOS systems)
# On NixOS, modules are loaded via os/configuration.nix instead
{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs;
with nodePackages;
let
  mkConfigSymlink = x: config.lib.file.mkOutOfStoreSymlink "/home/leo/dotfiles/config/${x}";
  nvr = writeShellScriptBin "nvr" ''
    nvim --server $NVIM --remote-tab $(realpath $1)
  '';
  corePackages = [
    editorconfig-core-c
    bc
    jq
    gh
    helix
    gnutls
    binutils
    unzip
    fd
    (ripgrep.override { withPCRE2 = true; })
    texlive.combined.scheme-medium
    pandoc
    fzf
    bat
    socat
    coreutils
    wakatime-cli
    tldr
    cmake
    gcc
    python3
    tree-sitter
    lazygit
    nodejs
    cargo
    direnv
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
    trashy
    wezterm
    tmux
    tmuxPlugins.dracula
    koka
    nixd
    lua-language-server
    vtsls
    vscode-langservers-extracted
    yaml-language-server
    vscode-js-debug
    terraform-ls
    harper
    dockerfile-language-server
    purescript
    purescript-language-server
    ffmpeg
    yt-dlp
    ruff
    basedpyright
    rust-analyzer
    unrar
    psmisc
    gnumake
    nvr
    nix-tree
  ];
in
{
  programs.starship.enable = true;
  programs.zoxide.enable = true;
  programs.home-manager.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    accept-flake-config = true;
  };

  home = rec {
    username = "leo";
    homeDirectory = "/home/leo";
    stateVersion = "22.11";
    packages = corePackages ++ [
      nerd-fonts.iosevka
      nerd-fonts.symbols-only
    ];
    sessionVariables = {
      PAGER = "more";
      PNPM_HOME = "~/.local/share/pnpm";
      BUN_INSTALL = "~/.bun";
    };
    sessionPath = [
      sessionVariables.PNPM_HOME
      "${sessionVariables.BUN_INSTALL}/bin"
      "~/.cargo/bin"
    ];
    shellAliases = {
      ls = "ls --color=auto";
      yk = "xsel --clipboard --input";
      pp = "xsel --clipboard --output";
      dps = "docker ps --format 'table{{.Names}}\t{{.Status}}\t{{.Ports}}'";
      dbr = "docker run --rm -it $(docker build -q .)";
    };
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = [ "Iosevka Nerd Font Mono" ];
    defaultFonts.serif = [ "FreeSerif" ];
    defaultFonts.sansSerif = [ "Fira Sans" ];
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    historySubstringSearch.enable = true;
    initContent = ''
      # unfuck direnv nix shell
      NIX_PATHS=$(echo $PATH | tr ':' '\n' | grep "/nix/" | tail -n +2 | tr '\n' ':')
      if [[ $NIX_PATHS ]]; then
        PATH=$NIX_PATHS$PATH
      fi

      # auto nix develop
      nix_flake_cd() {
        if [[ -f "flake.nix" && -z "$NIX_SHELL_LEVEL" ]]; then
          export NIX_SHELL_LEVEL=1
          nix develop --impure
          export NIX_SHELL_LEVEL=
        fi
      }

      # autoload -U add-zsh-hook
      # add-zsh-hook chpwd nix_flake_cd && nix_flake_cd
    '';
  };

  programs.fish.enable = true;
  programs.bash.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user.email = "levimanga@gmail.com";
      user.name = "chaoky";
    };
  };

  programs.difftastic = {
    enable = true;
    git = {
      enable = true;
      diffToolMode = true;
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.vicinae = {
    enable = true;
  };

  home.file = {
    ".config/doom".source = mkConfigSymlink "doom";
    ".config/nvim".source = mkConfigSymlink "nvim";
    ".config/tmux".source = mkConfigSymlink "tmux";
    ".config/ghostty".source = mkConfigSymlink "ghostty";
    ".config/helix".source = mkConfigSymlink "helix";
    ".config/wezterm".source = mkConfigSymlink "wezterm";
    ".ssh".source = mkConfigSymlink "ssh";
    ".wakatime.cfg2" = {
      text = ''
        [settings]
        api_url=https://waka.leo.camp/api
        api_key=????
      '';
    };
  };

  home.activation.linkDesktopFiles = lib.hm.dag.entryAfter [ "installPackages" ] ''
    if [ -d "${config.home.profileDirectory}/share/applications" ]; then
      rm -rf ${config.home.homeDirectory}/.local/share/applications
      mkdir -p ${config.home.homeDirectory}/.local/share/applications
      for file in ${config.home.profileDirectory}/share/applications/*; do
        ln -sf "$file" ${config.home.homeDirectory}/.local/share/applications/
      done
    fi
  '';
}
