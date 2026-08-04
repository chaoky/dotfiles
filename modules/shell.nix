{
  flake.nixosModules.shell =
    { pkgs, ... }:
    {
      programs.fish.enable = true;
      users.users.leo.shell = pkgs.fish;

      home-manager.users.leo = {
        programs.starship = {
          enable = true;
          settings = {
            package.disabled = true;
            nix_shell = {
              symbol = "󱄅 ";
              format = "[$symbol]($style)";
            };
          };
        };
        programs.zoxide.enable = true;
        programs.bash = {
          enable = true;
          initExtra = ''
            export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
          '';
        };

        home.packages = [ pkgs.fnm ];
        programs.fish = {
          enable = true;
          shellInit = ''
            set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/gcr/ssh"
          '';
          interactiveShellInit = ''
            devenv hook fish | source
          '';
          shellInitLast = ''
            fnm env --use-on-cd --shell fish --version-file-strategy recursive --corepack-enabled | source
            fish_add_path $FNM_MULTISHELL_PATH/bin
          '';
        };

        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        home.shellAliases = {
          ls = "ls --color=auto";
          yk = "wl-copy";
          pp = "wl-paste";
          dps = "docker ps --format 'table{{.Names}}\t{{.Status}}\t{{.Ports}}'";
          dbr = "docker run --rm -it $(docker build -q .)";
        };
      };
    };
}
