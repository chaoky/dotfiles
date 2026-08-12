{
  flake.nixosModules.shell =
    { pkgs, inputs, ... }:
    let
      zjstatus = inputs.zjstatus.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      programs.fish.enable = true;
      users.users.leo.shell = pkgs.fish;

      home-manager.users.leo = { ... }: {
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
        programs.zellij = {
          enable = true;
          enableFishIntegration = true;
          enableBashIntegration = false;
        };
        # Kept out of ~/.config/zellij: dotfiles.nix symlinks that whole tree
        # back into the repo, so nothing generated can live there. The stable
        # path matters — zellij caches plugin permissions per location, so
        # pointing layouts at this instead of the store path means version
        # bumps don't re-trigger the permission prompt.
        xdg.dataFile."zellij/plugins/zjstatus.wasm".source =
          "${zjstatus}/bin/zjstatus.wasm";
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
