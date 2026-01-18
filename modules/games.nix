{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.local.games;
in
{
  options.local.games = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable games module";
    };
  };

  config = mkIf cfg.enable {
    #xbox controller
    hardware.bluetooth.settings = {
      General = {
        Privacy = "device";
        JustWorksRepairing = "always";
        Class = "0x000100";
        FastConnectable = true;
      };
    };

    boot.extraModprobeConfig = ''
      options bluetooth disable_ertm=Y
    '';

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      extest.enable = true;
    };

    home-manager.users.leo.home.packages = with pkgs; [
      gdlauncher-carbon
      lutris
      wineWowPackages.stable
      winetricks
      wine-wayland
      krita
      gimp3
      inkscape
      blender
      libreoffice-fresh
      fontforge-gtk
      tiled
      ldtk
      aseprite
      ryubing
    ];
  };
}
