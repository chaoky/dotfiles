{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.local.system;
in
{
  options.local.system = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable system module";
    };
    hostname = mkOption {
      type = types.str;
      default = "stanbot-nix";
      description = "The hostname of the machine";
    };
  };

  config = mkIf cfg.enable {
    system.stateVersion = "23.11";

    # Boot
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;

    # Locale
    time.timeZone = lib.mkForce null;
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
    console.keyMap = "br-abnt2";

    # Nix settings
    nix.settings = {
      trusted-users = [
        "root"
        "leo"
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      accept-flake-config = true;
      auto-optimise-store = true;
      warn-dirty = false;
    };

    # Automatic garbage collection
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # Periodic store optimization
    nix.optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };

    # Nice nixos-rebuild wrapper
    programs.nh = {
      enable = true;
      flake = "/home/leo/dotfiles";
    };

    # User
    users.users.leo = {
      isNormalUser = true;
      description = "leo";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };

    # Networking
    networking.hostName = cfg.hostname;
    networking.networkmanager.enable = true;

    networking.firewall = {
      checkReversePath = false;
      enable = true;
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

    services.samba = {
      enable = true;
      openFirewall = true;
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

    environment.systemPackages = with pkgs; [
      wireguard-tools
      protonvpn-gui
    ];

    # Home-manager
    home-manager.useGlobalPkgs = true;
    home-manager.backupFileExtension = "backup";

    home-manager.users.leo =
      { config, lib, ... }:
      {
        programs.home-manager.enable = true;

        home = {
          username = "leo";
          homeDirectory = "/home/leo";
          stateVersion = "22.11";
          sessionVariables = {
            PAGER = "more";
            PNPM_HOME = "~/.local/share/pnpm";
            BUN_INSTALL = "~/.bun";
          };
          sessionPath = [
            "~/.local/share/pnpm"
            "~/.bun/bin"
            "~/.cargo/bin"
          ];
        };

        home.activation.linkDesktopFiles = lib.hm.dag.entryAfter [ "installPackages" ] ''
          if [ -d "${config.home.profileDirectory}/share/applications" ]; then
            rm -rf ${config.home.homeDirectory}/.local/share/applications
            mkdir -p ${config.home.homeDirectory}/.local/share/applications
            for file in ${config.home.profileDirectory}/share/applications/*; do
              ln -sf "$file" ${config.home.homeDirectory}/.local/share/applications/
            done
          fi
        '';
      };
  };
}
