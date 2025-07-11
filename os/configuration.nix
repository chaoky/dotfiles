{
  pkgs,
  ...
}:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  hardware.keyboard.qmk.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  virtualisation.docker.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.gnome-keyring.enable = true;
  environment.systemPackages = with pkgs.gnomeExtensions; [
    appindicator
    pano
    espresso
  ];

  # Enable Cosmic Desktop https://github.com/lilyinstarlight/nixos-cosmic
  # services.desktopManager.cosmic.enable = true;
  # services.displayManager.cosmic-greeter.enable = true;
  # environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
  # systemd.packages = [ pkgs.observatory ];
  # systemd.services.monitord.wantedBy = [ "multi-user.target" ];

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "br";
      variant = "thinkpad";
    };
  };

  # Configure console keymap
  console.keyMap = "br-abnt2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  # sound.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  system.stateVersion = "23.11";
}
