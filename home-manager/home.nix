{ pkgs, ... }:
let
  packages = import ./packages.nix { inherit pkgs; };
in
{
  targets.genericLinux.enable = true;
  fonts.fontconfig.enable = true;
  home.activation = {
    linkDesktopApplications = {
      after = [ "writeBoundary" "createXdgUserDirectories" ];
      before = [ ];
      data = "/usr/bin/update-desktop-database";
    };
  };

  home = {
    username = "lordie";
    homeDirectory = "/home/lordie";
    stateVersion = "22.11";
    packages = with builtins; (concatLists (attrValues packages));
  };

  dconf.settings = {
    "org/gnome/shell".enabled-extensions =
      (map (extension: extension.extensionUuid) packages.gnome)
      #NOTE popos only
      #NOTE requires enabling the extension by hand once
      ++ ["system76-power@system76.com"];
  };

  programs = {
    home-manager.enable = true;
    bash.enable = true;
    fish = import ./fish/fish.nix { inherit pkgs; };
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
