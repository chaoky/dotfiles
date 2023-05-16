{ pkgs, ... }:

let packages = import ./packages/packages.nix { inherit pkgs; };
in {
  imports = [ ./packages/docker.nix ./packages/gnome.nix ];
  fonts.fontconfig.enable = true;

  # services.docker.enable = true;
  # programs.gnome.enable = true;

  home = {
    username = "chaoky";
    homeDirectory = "/home/chaoky";
    stateVersion = "22.11";
    packages = with builtins; (concatLists (attrValues packages));
  };

  programs = {
    home-manager.enable = true;
    fish = import ./fish/fish.nix { inherit pkgs; };
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
