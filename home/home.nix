{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins;
let
  wsl = {
    options.wsl = mkOption {
      type = types.bool;
      default = false;
    };
  };
  mkConfigSymlink = x: config.lib.file.mkOutOfStoreSymlink "/home/leo/dotfiles/config/${x}";
in
{
  imports = [
    ./bin.nix
    ./emacs.nix
    wsl
  ];
  local.bin.enable = true;
  local.emacs.enable = false;

  fonts.fontconfig = {
    enable = true;
    defaultFonts.monospace = [ "Iosevka Nerd Font Mono" ];
    defaultFonts.serif = [ "FreeSerif" ];
    defaultFonts.sansSerif = [ "Fira Sans" ];
  };

  programs.starship.enable = true;
  programs.zoxide.enable = true;
  programs.carapace.enable = true;
  programs.home-manager.enable = true;

  nix = {
    package = mkIf config.wsl pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  home = rec {
    username = "leo";
    homeDirectory = "/home/leo";
    stateVersion = "22.11";
    sessionVariables = {
      PAGER = "more";
      # SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";
      PNPM_HOME = "/home/leo/.local/share/pnpm";
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
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    userEmail = "levimanga@gmail.com";
    userName = "chaoky";
  };

  home.file = {
    ".config/doom".source = mkConfigSymlink "doom";
    ".config/nvim".source = mkConfigSymlink "nvim";
    ".config/tmux".source = mkConfigSymlink "tmux";
    ".config/ghostty".source = mkConfigSymlink "ghostty";
    ".ssh".source = mkConfigSymlink "ssh";
    ".wakatime.cfg2" = {
      text = ''
        [settings]
        api_url=https://waka.leo.camp/api
        api_key=????
      '';
    };
  };
}
