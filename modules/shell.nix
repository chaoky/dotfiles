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
        programs.bash.enable = true;

        home.packages = [ pkgs.fnm ];
        programs.fish = {
          enable = true;
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
          yk = "xsel --clipboard --input";
          pp = "xsel --clipboard --output";
          dps = "docker ps --format 'table{{.Names}}\t{{.Status}}\t{{.Ports}}'";
          dbr = "docker run --rm -it $(docker build -q .)";
        };
      };
    };
}
