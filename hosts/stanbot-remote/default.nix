{ inputs, withSystem, ... }:
let
  serverDomain = "tail.leo.camp";
  system = "x86_64-linux";

  stanbotRemoteModules = [
    inputs.disko.nixosModules.disko
    inputs.headscale.nixosModules.default
    ./_hardware.nix
    stanbotRemoteNixosModule
  ];

  stanbotRemoteNixosModule = { config, pkgs, lib, ... }:
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
            8189 # MediaMTX WebRTC (TCP fallback)
          ];
          allowedUDPPorts = [
            8189 # MediaMTX WebRTC
            41641 # Tailscale (work tailnet)
            41642 # Tailscale (personal tailnet)
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

        # NixOS's tailscaled-autoconnect only invokes `tailscale up` once at
        # first-auth, so --accept-dns=false in extraUpFlags stops applying on
        # subsequent restarts/reconnects and the daemon grabs resolv.conf again.
        # Re-assert the setting on every daemon start.
        systemd.services.tailscaled.serviceConfig.ExecStartPost = pkgs.writeShellScript "tailscaled-no-dns" ''
          for i in $(seq 1 60); do
            if ${pkgs.tailscale}/bin/tailscale ip -4 >/dev/null 2>&1; then
              ${pkgs.tailscale}/bin/tailscale set --accept-dns=false
              exit 0
            fi
            sleep 2
          done
          exit 1
        '';

        # Second tailscale instance for personal network, advertising work routes
        systemd.services.tailscaled-personal = {
          description = "Tailscale node agent (personal network)";
          after = [ "network.target" "tailscaled.service" "headscale.service" ];
          wants = [ "network.target" ];
          partOf = [ "tailscaled.service" ];
          wantedBy = [ "multi-user.target" "tailscaled.service" ];
          serviceConfig = {
            ExecStart = "${pkgs.tailscale}/bin/tailscaled --state=/var/lib/tailscale-personal/tailscaled.state --socket=/var/run/tailscale-personal/tailscaled.sock --tun=tailscale1 --port=41642";
            ExecStartPost = pkgs.writeShellScript "tailscaled-personal-up" ''
              for i in $(seq 1 10); do
                ${pkgs.tailscale}/bin/tailscale --socket=/var/run/tailscale-personal/tailscaled.sock set \
                  --advertise-routes=10.20.0.0/16,10.40.0.0/16,10.60.0.0/16 && exit 0
                sleep 1
              done
              exit 1
            '';
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
                  "rds.amazonaws.com" = [ "10.60.0.2" ];
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
                    "vpc-dev" = "10.20.0.0/16";
                    "vpc-prod" = "10.40.0.0/16";
                    "vpc" = "10.60.0.0/16";
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
                      "10.40.0.0/16" = [ "group:admin" ];
                      "10.60.0.0/16" = [ "group:admin" ];
                    };
                  };
                }
              );
            };
          };
        };

        services.syncthing = {
          enable = true;
          user = "syncthing";
          group = "syncthing";
          dataDir = "/var/lib/syncthing";
          configDir = "/var/lib/syncthing/.config/syncthing";
          openDefaultPorts = false;
          guiAddress = "0.0.0.0:8384";
          overrideDevices = false;
          overrideFolders = false;
        };

        services.caddy = {
          enable = true;
          email = acmeEmail;
          virtualHosts.${cfg.domain}.extraConfig = ''
            reverse_proxy 127.0.0.1:${toString config.services.headscale.port}
          '';
          virtualHosts."live.leo.camp".extraConfig = ''
            @site path / /index.html /avatars/*
            handle @site {
              root * ${./live}
              file_server
            }
            # the only API endpoint exposed publicly: read-only stream list
            @paths {
              method GET
              path /api/paths
            }
            handle @paths {
              rewrite * /v3/paths/list
              reverse_proxy 127.0.0.1:9997
            }
            # viewer names per stream, IPs stripped by mediamtx-viewers
            @viewers {
              method GET
              path /api/viewers
            }
            handle @viewers {
              rewrite * /
              reverse_proxy 127.0.0.1:9998
            }
            # watch page (WHIP/WHEP sub-paths fall through to mediamtx)
            @watch {
              method GET
              path_regexp ^/[a-z0-9_-]+/?$
            }
            handle @watch {
              root * ${./live}
              rewrite * /watch.html
              templates
              file_server
            }
            # players, WHIP and WHEP
            handle {
              reverse_proxy 127.0.0.1:8889
            }
          '';
        };

        services.mediamtx = {
          enable = true;
          settings = {
            # no auth: anyone may publish/read/playback; API/metrics stay localhost-only
            authInternalUsers = [
              {
                user = "any";
                pass = "";
                ips = [ ];
                permissions = [
                  { action = "publish"; }
                  { action = "read"; }
                  { action = "playback"; }
                ];
              }
              {
                user = "any";
                pass = "";
                ips = [
                  "127.0.0.1"
                  "::1"
                ];
                permissions = [
                  { action = "api"; }
                  { action = "metrics"; }
                  { action = "pprof"; }
                ];
              }
            ];
            api = true;
            apiAddress = "127.0.0.1:9997"; # stream list exposed read-only via caddy
            webrtcAddress = "127.0.0.1:8889"; # HTTP/WHIP/WHEP only via caddy
            webrtcLocalUDPAddress = ":8189";
            webrtcLocalTCPAddress = ":8189"; # fallback for UDP-blocked clients
            webrtcAdditionalHosts = [ "live.leo.camp" ];
            paths.all_others = { }; # accept any stream name
          };
        };

        # Stateless filter over the mediamtx API: exposes only {path, viewer}
        # of reading WebRTC sessions, never remote addresses.
        systemd.sockets.mediamtx-viewers = {
          wantedBy = [ "sockets.target" ];
          socketConfig = {
            ListenStream = "127.0.0.1:9998";
            Accept = true;
          };
        };
        systemd.services."mediamtx-viewers@" = {
          serviceConfig = {
            DynamicUser = true;
            StandardInput = "socket";
            StandardOutput = "socket";
            ExecStart = pkgs.writeShellScript "mediamtx-viewers" ''
              export LC_ALL=C # byte-length Content-Length
              while IFS= read -r line && [ "''${line%$'\r'}" != "" ]; do :; done
              body=$(${pkgs.curl}/bin/curl -sf 127.0.0.1:9997/v3/webrtcsessions/list \
                | ${pkgs.jq}/bin/jq -c '[.items[] | select(.state == "read")
                  | (.query | split("&") | map(split("=") | {(.[0]): (.[1] // "")}) | add // {}) as $q
                  | {path,
                     viewer: ($q.viewer // "" | gsub("%20"; " ") | gsub("[^A-Za-z0-9 _-]"; "") | .[0:20]),
                     vid: ($q.vid // "" | gsub("[^A-Za-z0-9]"; "") | .[0:16])}]') || body='[]'
              printf 'HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s' "''${#body}" "$body"
            '';
          };
        };

        # State migrated from the old host carries foreign UIDs; re-own it.
        systemd.tmpfiles.rules = [
          "Z /var/lib/headscale - headscale headscale -"
          "Z /var/lib/syncthing - syncthing syncthing -"
          "Z /var/lib/caddy - caddy caddy -"
        ];

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
    nixosModules.stanbot-remote = stanbotRemoteNixosModule;

    nixosConfigurations.stanbot-remote = inputs.nixpkgs.lib.nixosSystem {
      modules = stanbotRemoteModules ++ [
        { nixpkgs.pkgs = withSystem system ({ pkgs, ... }: pkgs); }
        { services.headscale-server.domain = serverDomain; }
      ];
    };

    colmenaHive = inputs.colmena.lib.makeHive {
      meta.nixpkgs = withSystem system ({ pkgs, ... }: pkgs);
      stanbot-remote = {
        imports = stanbotRemoteModules;
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
      # nix run .#colmena -- apply --on stanbot-remote
      colmena.program = inputs.colmena.packages.${system}.colmena;
      # nix run .#nixos-anywhere -- --flake .#stanbot-remote --target-host ubuntu@201.23.80.203
      nixos-anywhere.program = inputs.nixos-anywhere.packages.${system}.nixos-anywhere;
    };
  };
}
