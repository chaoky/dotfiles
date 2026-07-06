{
  flake.nixosModules.audio =
    { pkgs, ... }:
    {
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

        # WirePlumber restores each device's last-used profile before our
        # priority rules run, so a stale stored profile (e.g. an old iec958 or
        # surround selection) could override them. Disable just the profile-state
        # hook so the analog-stereo pins below are always authoritative.
        # Route/default-node/stream state stay on, so the default output and
        # remembered volumes persist.
        wireplumber.extraConfig."99-pin-profiles" = {
          "wireplumber.profiles".main."hooks.device.profile.state" = "disabled";
        };

        # Trim redundant per-device profiles so GNOME shows a single entry per
        # device instead of one per (unused) profile.
        wireplumber.extraConfig."99-hide-outputs" = {
          "monitor.alsa.rules" = [
            # Disable the NVIDIA GPU's HDMI audio card entirely.
            {
              matches = [ { "device.name" = "alsa_card.pci-0000_07_00.1"; } ];
              actions.update-props."device.disabled" = true;
            }
            # Give the A80, A50 and onboard card the stock analog-only.conf
            # profile-set: it drops the digital (IEC958) output (and Pro Audio),
            # so each shows a single analog output in GNOME instead of two.
            {
              matches = [
                { "device.name" = "alsa_card.usb-EDIFIER_AIRPULSE_A80-00"; }
                { "device.name" = "alsa_card.usb-Logitech_A50-00"; }
                { "device.name" = "alsa_card.pci-0000_09_00.4"; }
              ];
              actions.update-props = {
                "device.profile-set" = "analog-only.conf";
                "api.acp.disable-pro-audio" = true;
              };
            }
          ];

          # Default profiles: analog stereo output for each (keeping the mic /
          # line-in input where the card has one).
          "device.profile.priority.rules" = [
            {
              matches = [ { "device.name" = "alsa_card.usb-EDIFIER_AIRPULSE_A80-00"; } ];
              actions.update-props."priorities" = [ "output:analog-stereo" ];
            }
            {
              matches = [ { "device.name" = "alsa_card.usb-Logitech_A50-00"; } ];
              actions.update-props."priorities" = [ "output:analog-stereo+input:mono-fallback" ];
            }
            {
              matches = [ { "device.name" = "alsa_card.pci-0000_09_00.4"; } ];
              actions.update-props."priorities" = [ "output:analog-stereo+input:analog-stereo" ];
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

      home-manager.users.leo.home.packages = with pkgs; [
        easyeffects
        alsa-utils
        crosspipe
        qpwgraph
      ];
    };
}
