{ inputs, withSystem, ... }:
let
  serverDomain = "tail.leo.camp";
  system = "x86_64-linux";

  headscaleServerModules = [
    inputs.disko.nixosModules.disko
    inputs.headscale.nixosModules.default
    ../hosts/main-vps.nix
    {
      nixpkgs.pkgs = withSystem system ({ pkgs, ... }: pkgs);
    }
  ];
in
{
  flake = {
    nixosConfigurations.headscale-server = inputs.nixpkgs.lib.nixosSystem {
      modules = headscaleServerModules ++ [
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
}
