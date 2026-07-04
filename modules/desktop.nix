{
  flake.nixosModules.desktop =
    { pkgs, ... }:
    let
      extensions = with pkgs.gnomeExtensions; [
        appindicator
        places-status-indicator
        quick-settings-audio-panel
        color-picker
        clipboard-indicator
        tiling-shell
      ];
    in
    {
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
            "default.clock.quantum" = 1024;
            "default.clock.min-quantum" = 512;
            "default.clock.max-quantum" = 2048;
          };
        };

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

        # Hide unwanted audio outputs from GNOME.
        wireplumber.extraConfig."99-hide-outputs" = {
          # Disable the NVIDIA GPU's HDMI audio card entirely.
          "monitor.alsa.rules" = [
            {
              matches = [ { "device.name" = "alsa_card.pci-0000_07_00.1"; } ];
              actions.update-props."device.disabled" = true;
            }
          ];

          # Force the AIRPULSE A80 to analog output so the digital
          # (IEC958) sink is never offered.
          "device.profile.priority.rules" = [
            {
              matches = [ { "device.name" = "alsa_card.usb-EDIFIER_AIRPULSE_A80-00"; } ];
              actions.update-props."priorities" = [ "output:analog-stereo" ];
            }
          ];
        };

        # Virtual mic: a null sink whose monitor is exposed as a source.
        # Route apps (and optionally a loopback of the real mic) into "virtmic",
        # then pick "Monitor of virtmic" as the input device in Zoom/Discord/OBS.
        extraConfig.pipewire."99-virtmic" = {
          "context.modules" = [
            {
              name = "libpipewire-module-loopback";
              args = {
                "node.description" = "Virtual Mic";
                "capture.props" = {
                  "node.name" = "virtmic";
                  "node.description" = "Mic Feed";
                  "media.class" = "Audio/Sink";
                  "audio.position" = [
                    "FL"
                    "FR"
                  ];
                };
                "playback.props" = {
                  "node.name" = "virtmic-source";
                  "node.description" = "Virtual Mic";
                  "media.class" = "Audio/Source";
                  "audio.position" = [
                    "FL"
                    "FR"
                  ];
                };
              };
            }
          ];
        };
      };

      home-manager.users.leo = {
        home.packages =
          extensions
          ++ (with pkgs; [
            # Audio
            easyeffects
            alsa-utils
            crosspipe
            qpwgraph
            # Fonts
            nerd-fonts.iosevka
            nerd-fonts.symbols-only
            # Terminals
            wezterm
            # GUI apps
            redisinsight
            discord
            # stoat-desktop
            zed-editor
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
            jetbrains.datagrip
            postman
            code-cursor
            spotify
            gnome-frog
            gnome-tweaks
            stremio-linux-shell
          ]);

        fonts.fontconfig = {
          enable = true;
          defaultFonts.monospace = [ "Iosevka Nerd Font Mono" ];
          defaultFonts.serif = [ "FreeSerif" ];
          defaultFonts.sansSerif = [ "Fira Sans" ];
        };
      };
    };
}
