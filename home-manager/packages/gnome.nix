{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.programs.gnome;
  extensions = with pkgs.gnomeExtensions; [
    pano
    monitor-window-switcher-2
    appindicator
    espresso
  ];
in {
  options.programs.gnome = { enable = mkEnableOption "gnome module"; };
  config = mkIf cfg.enable {
    home.packages = extensions;
    targets.genericLinux.enable = true;
    dconf.settings = {
      "org/gnome/shell".enabled-extensions =
        (map (extension: extension.extensionUuid) extensions)
        #NOTE popos only
        #NOTE requires enabling the extension by hand once
        ++ [ "system76-power@system76.com" ];
    };
  };
}
