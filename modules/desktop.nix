{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.local.desktop;
  extensions = with pkgs.gnomeExtensions; [
    appindicator
    places-status-indicator
  ];
in
{
  options.local.desktop = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable desktop module";
    };
  };

  config = mkIf cfg.enable {
    # GNOME
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    services.gnome.gnome-keyring.enable = true;

    services.xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "colemak";
      };
    };

    environment.systemPackages = with pkgs; [
      gnome-tweaks
    ];

    # Audio (Pipewire)
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    home-manager.users.leo = {
      # GNOME extensions
      dconf.settings = {
        "org/gnome/shell".enabled-extensions = (map (extension: extension.extensionUuid) extensions) ++ [
          "system76-power@system76.com"
        ];
      };

      # Audio packages
      home.packages = with pkgs; [
        easyeffects
        alsa-utils
        helvum
        nerd-fonts.iosevka
        nerd-fonts.symbols-only
      ];

      # Fonts
      fonts.fontconfig = {
        enable = true;
        defaultFonts.monospace = [ "Iosevka Nerd Font Mono" ];
        defaultFonts.serif = [ "FreeSerif" ];
        defaultFonts.sansSerif = [ "Fira Sans" ];
      };
    };
  };
}
