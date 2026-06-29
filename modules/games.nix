{
  flake.nixosModules.games =
    { pkgs, ... }:
    {
      # Xbox controller
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

      # GTA Online on Linux: block BattlEye DNS so the runtime no-ops
      # https://steamcommunity.com/sharedfiles/filedetails/?id=3658540317
      networking.extraHosts = ''
        0.0.0.0 paradise-s1.battleye.com
        0.0.0.0 test-s1.battleye.com
        0.0.0.0 paradiseenhanced-s1.battleye.com
      '';

      home-manager.users.leo.home.packages = with pkgs; [
        gdlauncher-carbon
        lutris
        wineWow64Packages.stable
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
