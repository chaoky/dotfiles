{ pkgs, lib, config, ... }:
with lib;
let
  packages = import ./packages/packages.nix { inherit pkgs; };
  wsl = {
    options.wsl = mkOption {
      type = types.bool;
    };
    config = mkIf (!config.wsl) {
      local.sway.enable = true;
    };
  };
in
{
  imports = [ ./bin.nix ./sway.nix ./emacs.nix wsl ];
  local.bin.enable = true;
  local.emacs.enable = true;

  fonts.fontconfig.enable = true;
  programs.starship.enable = true;
  programs.zoxide.enable = true;
  programs.carapace.enable = true;
  programs.home-manager.enable = true;

  home = rec {
    username = "chaoky";
    homeDirectory = "/home/chaoky";
    stateVersion = "22.11";
    sessionVariables = {
      PAGER = "more";
      SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh";
      PNPM_HOME = "/home/chaoky/.local/share/pnpm";
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
      hm = "home-manager switch --flake ~/dotfiles/home-manager/#chaoky";
    };
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    initExtra = ''
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
}
