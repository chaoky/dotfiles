{ config
, pkgs
, lib
, modulesPath
, ...
}:
let
  cfg = config.services.headscale-server;
  acmeEmail = "levimanga@gmail.com";
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  options.services.headscale-server.domain = lib.mkOption {
    type = lib.types.str;
    description = "Domain for headscale server";
  };

  config = {
    disko.devices.disk.main = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02";
          };
          ESP = {
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };

    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    boot.initrd.availableKernelModules = [
      "ata_piix"
      "uhci_hcd"
      "virtio_pci"
      "virtio_scsi"
      "sd_mod"
      "sr_mod"
    ];

    networking.hostName = "headscale-server";
    networking.useDHCP = true;
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
      ];
    };

    system.stateVersion = "23.11";
    time.timeZone = "UTC";
    i18n.defaultLocale = "en_US.UTF-8";

    nix.settings = {
      trusted-users = [ "root" ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      accept-flake-config = true;
      auto-optimise-store = true;
    };

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
      };
    };

    users.users.root.openssh.authorizedKeys.keys = [
      (builtins.readFile ../config/ssh/id_rsa.pub)
    ];

    environment.systemPackages = with pkgs; [
      vim
      htop
      curl
      git
      fish
    ];

    services.headscale = {
      enable = true;
      address = "127.0.0.1";
      port = 8080;
      settings = {
        server_url = "https://${cfg.domain}";
        prefixes = {
          v4 = "100.64.0.0/10";
          v6 = "fd7a:115c:a1e0::/48";
          allocation = "sequential";
        };
        dns = {
          magic_dns = true;
          base_domain = "in.${cfg.domain}";
          override_local_dns = true;
          nameservers.global = [
            "1.1.1.1"
            "8.8.8.8"
          ];
        };
        derp = {
          urls = [ "https://controlplane.tailscale.com/derpmap/default" ];
          auto_update_enabled = true;
          update_frequency = "24h";
        };
        database = {
          type = "sqlite";
          sqlite = {
            path = "/var/lib/headscale/db.sqlite";
            write_ahead_log = true;
          };
        };
        log = {
          level = "info";
          format = "text";
        };
        policy = {
          mode = "file";
          path = pkgs.writeText "headscale-acl.json" (
            builtins.toJSON {
              acls = [
                {
                  action = "accept";
                  src = [ "*" ];
                  dst = [ "*:*" ];
                }
              ];
              ssh = [
                {
                  action = "accept";
                  src = [ "autogroup:member" ];
                  dst = [ "autogroup:member" ];
                  users = [
                    "autogroup:nonroot"
                    "root"
                  ];
                }
              ];
            }
          );
        };
      };
    };

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts.${cfg.domain} = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://127.0.0.1:${toString config.services.headscale.port}";
        locations."/".proxyWebsockets = true;
      };
    };

    security.acme = {
      acceptTerms = true;
      defaults.email = acmeEmail;
    };
  };
}
