{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.local.shell;
in
{
  options.local.shell = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable shell module";
    };
  };

  config = mkIf cfg.enable {
    programs.zsh.enable = true;
    programs.fish.enable = true;

    users.users.leo.shell = pkgs.fish;

    home-manager.users.leo = {
      programs.starship.enable = true;
      programs.zoxide.enable = true;

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

      home.shellAliases = {
        ls = "ls --color=auto";
        yk = "xsel --clipboard --input";
        pp = "xsel --clipboard --output";
        dps = "docker ps --format 'table{{.Names}}\t{{.Status}}\t{{.Ports}}'";
        dbr = "docker run --rm -it $(docker build -q .)";
      };
    };
  };
}
