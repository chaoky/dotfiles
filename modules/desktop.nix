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

      # Analog-only ALSA card profile for the AIRPULSE A80, so the redundant
      # digital (IEC958) output profile is never generated (and thus never
      # shown by GNOME). Same as the stock analog-stereo mapping, minus iec958.
      airpulseProfileSet = pkgs.writeText "airpulse-a80.conf" ''
        [General]
        auto-profiles = yes

        [Mapping analog-stereo]
        device-strings = front:%f
        channel-map = left,right
        paths-output = analog-output analog-output-lineout analog-output-speaker analog-output-headphones analog-output-headphones-2
        priority = 15

        [Mapping stereo-fallback]
        device-strings = hw:%f
        fallback = yes
        channel-map = front-left,front-right
        paths-output = analog-output analog-output-lineout analog-output-speaker analog-output-headphones analog-output-headphones-2
        priority = 1
      '';

      # ACP looks for profile-sets in a single directory; override it with a
      # copy of the stock sets plus our custom A80 one so other cards still work.
      acpProfileSets = pkgs.runCommand "acp-profile-sets" { } ''
        mkdir -p $out
        cp ${pkgs.pipewire}/share/alsa-card-profile/mixer/profile-sets/*.conf $out/
        cp ${airpulseProfileSet} $out/airpulse-a80.conf
      '';
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

      # Custom ACP profile-set directory (adds the analog-only A80 profile).
      # WirePlumber loads the ALSA SPA plugin, so it needs this in its env.
      systemd.user.services.wireplumber.environment.ACP_PROFILES_DIR = "${acpProfileSets}";
      systemd.user.services.pipewire.environment.ACP_PROFILES_DIR = "${acpProfileSets}";
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
          "monitor.alsa.rules" = [
            {
            # Disable the NVIDIA GPU's HDMI audio card entirely.
              matches = [ { "device.name" = "alsa_card.pci-0000_07_00.1"; } ];
              actions.update-props."device.disabled" = true;
            }
          ];
            # Give the AIRPULSE A80 an analog-only profile-set so the digital
            # (IEC958) output profile isn't created.
            {
              matches = [ { "device.name" = "alsa_card.usb-EDIFIER_AIRPULSE_A80-00"; } ];
              actions.update-props = {
                "device.profile-set" = "airpulse-a80.conf";
                "api.acp.disable-pro-audio" = true;
              };
            }
            # Cleaner names for the visible outputs.
            {
              matches = [ { "node.name" = "alsa_output.usb-EDIFIER_AIRPULSE_A80-00.analog-stereo"; } ];
              actions.update-props."node.description" = "AIRPULSE A80";
            }
            {
              matches = [ { "node.name" = "alsa_output.pci-0000_09_00.4.iec958-stereo"; } ];
              actions.update-props."node.description" = "Line Out";
            }

          # Force analog as the default A80 profile.
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
