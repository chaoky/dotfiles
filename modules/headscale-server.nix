{ inputs, withSystem, ... }:
let
  serverDomain = "tail.leo.camp";
  system = "x86_64-linux";

  headscaleServerModules = [
    inputs.disko.nixosModules.disko
    inputs.headscale.nixosModules.default
    ../hosts/main-vps.nix
  ];
in
{
  flake = {
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
