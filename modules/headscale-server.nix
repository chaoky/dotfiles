{ inputs, withSystem, ... }:
let
  serverDomain = "tail.leo.camp";
  system = "x86_64-linux";

  headscaleServerModules = [
    inputs.disko.nixosModules.disko
    inputs.headscale.nixosModules.default
    ../hosts/main-vps.nix
    headscaleServerNixosModule
  ];

  headscaleServerNixosModule = { config, pkgs, lib, ... }:
    let
      cfg = config.services.headscale-server;
      acmeEmail = "levimanga@gmail.com";
    in
    {
      options.services.headscale-server.domain = lib.mkOption {
        type = lib.types.str;
        description = "Domain for headscale server";
      };

      config = {
        networking.firewall = {
          enable = true;
          allowedTCPPorts = [
            22
            80
            443
          ];
          allowedUDPPorts = [
            41641 # Tailscale
          ];
          trustedInterfaces = [ "tailscale0" "tailscale1" ];
        };

        environment.systemPackages = [ pkgs.tailscale ];

        # Tailscale client to connect to work network
        services.tailscale = {
          enable = true;
          extraUpFlags = [
            "--login-server=https://tail.oppizi.com"
            "--accept-routes"
          ];
        };

        # Second tailscale instance for personal network, advertising work routes
        systemd.services.tailscaled-personal = {
          description = "Tailscale node agent (personal network)";
          after = [ "network.target" "tailscaled.service" "headscale.service" ];
          wants = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.tailscale}/bin/tailscaled --state=/var/lib/tailscale-personal/tailscaled.state --socket=/var/run/tailscale-personal/tailscaled.sock --tun=tailscale1";
            StateDirectory = "tailscale-personal";
            RuntimeDirectory = "tailscale-personal";
            Restart = "on-failure";
          };
        };

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
              nameservers = {
                global = [
                  "1.1.1.1"
                  "8.8.8.8"
                ];
                split = {
                  "rds.amazonaws.com" = [ "10.20.0.2" ];
                };
              };
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
                  groups = {
                    "group:admin" = [ "*@leo.camp" ];
                  };
                  hosts = {
                    "work-vpc" = "10.20.0.0/16";
                  };
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
                  autoApprovers = {
                    routes = {
                      "10.20.0.0/16" = [ "group:admin" ];
                    };
                  };
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

        # Enable IP forwarding for subnet routing
        boot.kernel.sysctl = {
          "net.ipv4.ip_forward" = 1;
          "net.ipv6.conf.all.forwarding" = 1;
        };
      };
    };
in
{
  flake = {
    nixosModules.headscale-server = headscaleServerNixosModule;

    nixosConfigurations.headscale-server = inputs.nixpkgs.lib.nixosSystem {
      modules = headscaleServerModules ++ [
        { nixpkgs.pkgs = withSystem system ({ pkgs, ... }: pkgs); }
        { services.headscale-server.domain = serverDomain; }
      ];
    };

    colmenaHive = inputs.colmena.lib.makeHive {
      meta.nixpkgs = withSystem system ({ pkgs, ... }: pkgs);
      headscale-server = {
        imports = headscaleServerModules;
        services.headscale-server.domain = serverDomain;
        deployment = {
          targetHost = serverDomain;
          targetUser = "root";
        };
      };
    };
  };

  perSystem = { system, ... }: {
    apps = {
      # nix run .#colmena -- apply --on headscale-server
      colmena.program = inputs.colmena.packages.${system}.colmena;
      # nix run .#nixos-anywhere -- --flake .#headscale-server --target-host root@tail.leo.camp
      nixos-anywhere.program = inputs.nixos-anywhere.packages.${system}.nixos-anywhere;
    };
  };
}
