{
  pkgs,
  config,
  ...
}:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  #xbox controller
  hardware.bluetooth.settings = {
    General = {
      Privacy = "device";
      JustWorksRepairing = "always";
      Class = "0x000100";
      FastConnectable = true;
    };
  };

  boot = {
    extraModprobeConfig = ''
      options bluetooth disable_ertm=Y
    '';
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    shares = {
      public = {
        path = "/home/leo";
        writable = "true";
      };
    };
  };

  services.avahi = {
    enable = true;
    publish.enable = true;
    publish.userServices = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  networking.hostName = "stanbot-nix";
  networking.firewall = {
    enable = false;
    allowPing = true;
    allowedTCPPorts = [
      12345
      8080
      2056
    ];
    allowedUDPPorts = [
      12345
      8080
      2056
    ];
  };
  services.zerotierone = {
    enable = true;
    joinNetworks = [ "e4da7455b230f52a" ];
  };

  programs._1password-gui.enable = true;
  programs._1password.enable = true;

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-vaapi # optional AMD hardware acceleration
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # Enable networking
  networking.networkmanager.enable = true;

  services.flatpak.enable = true;

  # Set your time zone.
  time.timeZone = "America/Bahia";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  virtualisation.docker.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.gnome-keyring.enable = true;
  environment.systemPackages = with pkgs.gnomeExtensions; [
    appindicator
    pano
    vertical-workspaces
    places-status-indicator
  ];

  # Enable Cosmic Desktop https://github.com/lilyinstarlight/nixos-cosmic
  services.desktopManager.cosmic.enable = true;
  # services.displayManager.cosmic-greeter.enable = true;
  environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
  # systemd.packages = [ pkgs.observatory ];
  # systemd.services.monitord.wantedBy = [ "multi-user.target" ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "colemak";
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    extraConfig.pipewire = {
      "99-echo-cancel.conf" = {
        "context.modules" = [
          {
            name = "libpipewire-module-echo-cancel";
            args = {
              "library.name" = "aec/libspa-aec-webrtc";
              "monitor.mode" = true;
              "capture.props" = {
                "node.force-quantum" = 200;
                "node.passive" = true;
              };
            };
          }
        ];
      };
    };
  };

  nix.settings = {
    trusted-users = [
      "root"
      "leo"
    ];
  };

  users.users.leo = {
    isNormalUser = true;
    description = "leo";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };

  programs.zsh.enable = true;
  home-manager.users.leo = import ../home.nix;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";

  programs.nix-ld = {
    enable = true;
    libraries = [ pkgs.stdenv.cc.cc.lib ];
  };

  system.stateVersion = "23.11";
}
