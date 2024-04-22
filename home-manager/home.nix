{ pkgs, lib, config, ... }:
with lib;
let packages = import ./packages/packages.nix { inherit pkgs; };
in
{
  imports = [
    # ./docker.nix
    # ./gnome.nix
    ./fish/fish.nix
    ./bin.nix
    ./sway.nix
    {
      options.wsl = mkOption {
        type = types.bool;
      };
      config = mkIf (!config.wsl) {
        local.sway.enable = true;
      };
    }
  ];

  local.fish.enable = true;
  local.bin.enable = true;
  fonts.fontconfig.enable = true;
  programs.home-manager.enable = true;

  home = {
    username = "chaoky";
    homeDirectory = "/home/chaoky";
    stateVersion = "22.11";
  };

  programs.bash = {
    enable = true;
    profileExtra =
      "${pkgs.xorg.setxkbmap}/bin/setxkbmap -layout us -variant colemak";
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
