{
  flake.nixosModules.desktop =
    { pkgs, unstable, inputs, ... }:
    let
      zen-browser = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
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
      environment.gnome.excludePackages = [ pkgs.seahorse ];

      # Use the native GNOME/gcr passphrase dialog instead of the ugly
      # x11-ssh-askpass that NixOS wires up by default under X.
      programs.ssh.askPassword = "${pkgs.gcr_4}/libexec/gcr4-ssh-askpass";

      services.xserver = {
        enable = true;
        xkb = {
          layout = "us";
          variant = "colemak";
        };
      };

      home-manager.users.leo = {
        home.packages =
          extensions
          ++ (with pkgs; [
            # Fonts
            nerd-fonts.iosevka
            nerd-fonts.symbols-only
            # Terminals
            wezterm
            # GUI apps
            # redisinsight
            discord
            # stoat-desktop
            unstable.zed-editor
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
            zen-browser
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
