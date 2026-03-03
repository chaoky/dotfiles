{
  flake.nixosModules.shell =
    { pkgs, ... }:
    {
      programs.fish.enable = true;
      users.users.leo.shell = pkgs.fish;

      home-manager.users.leo = {
        programs.starship.enable = true;
        programs.zoxide.enable = true;
        programs.bash.enable = true;

        home.packages = [ pkgs.fnm ];
        programs.fish = {
          enable = true;
          shellInit = ''
            fnm env --use-on-cd --corepack-enabled --shell fish | source
          '';
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
