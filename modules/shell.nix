{
  flake.nixosModules.shell =
    { pkgs, username, ... }:
    {
      programs.fish.enable = true;
      users.users.${username}.shell = pkgs.fish;

      home-manager.users.${username} = { ... }: {
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

        home.packages = with pkgs; [ fnm tmux tmuxPlugins.resurrect tmuxPlugins.continuum ];
        programs.fish = {
          enable = true;
          shellInit = ''
            set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/gcr/ssh"
          '';
          interactiveShellInit = ''
            if status is-interactive; and not set -q TMUX; and test "$TERM" != dumb
                exec tmux new-session -A -s main
            end

            devenv hook fish | source
          '';
          shellInitLast = ''
            fnm env --use-on-cd --shell fish --version-file-strategy recursive --corepack-enabled | source
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
