{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.local.fish;
in
{
  options.local.fish = { enable = mkEnableOption "fish module"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      jump
      starship
    ];
    programs.fish = {
      enable = true;
      interactiveShellInit = builtins.readFile ./config.fish;
      plugins = [
        {
          name = "autopair";
          src = pkgs.fetchFromGitHub {
            owner = "jorgebucaran";
            repo = "autopair.fish";
            rev = "1.0.4";
            hash = "sha256-s1o188TlwpUQEN3X5MxUlD/2CFCpEkWu83U9O+wg3VU=";
          };
        }
        {
          name = "replay";
          src = pkgs.fetchFromGitHub {
            owner = "jorgebucaran";
            repo = "replay.fish";
            rev = "1.2.1";
            hash = "sha256-bM6+oAd/HXaVgpJMut8bwqO54Le33hwO9qet9paK1kY=";
          };
        }
        {
          name = "nix-env";
          src = pkgs.fetchFromGitHub {
            owner = "lilyball";
            repo = "nix-env.fish";
            rev = "master";
            hash = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
          };
        }
      ];
    };
  };
}
