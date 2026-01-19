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

    # Audio (Pipewire)
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      # Larger buffers to prevent distortion during high CPU load (gaming)
      extraConfig.pipewire."99-gaming" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 1024; # ~21ms buffer (default is 256-512)
          "default.clock.min-quantum" = 512;
          "default.clock.max-quantum" = 2048;
        };
      };

      # WirePlumber session manager config
      wireplumber.extraConfig."99-gaming" = {
        "wireplumber.settings" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [
            44100
            48000
            96000
          ];
        };
      };
    };

    home-manager.users.leo = {
      dconf.settings = {
        "org/gnome/shell".enabled-extensions = (map (extension: extension.extensionUuid) extensions);
      };

      home.packages =
        extensions
        ++ (with pkgs; [
          # Audio
          easyeffects
          alsa-utils
          helvum
          # Fonts
          nerd-fonts.iosevka
          nerd-fonts.symbols-only
          # Terminals
          wezterm
          # GUI apps
          redisinsight
          discord
          slack
          caffeine-ng
          qbittorrent
          vlc
          chromium
          firefox-devedition
          insomnia
          brave
          mongodb-compass
          dbeaver-bin
          postman
          code-cursor
          spotify
          gnome-frog
          gnome-tweaks
        ]);

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
