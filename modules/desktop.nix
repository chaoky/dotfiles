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
