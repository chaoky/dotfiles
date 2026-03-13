{
  description = "My Computers and Stuff";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://install.determinate.systems"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    colmena.url = "github:zhaofengli/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";
    headscale.url = "github:juanfont/headscale";
    headscale.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    let
      system = "x86_64-linux";
      lib = inputs.nixpkgs.lib;
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkSwitch =
        name:
        pkgs.writeShellScriptBin "nix-switch" "sudo nixos-rebuild switch --flake ~/dotfiles#${name} --accept-flake-config $@";

      mkHost =
        name: modules:
        lib.nixosSystem {
          inherit pkgs;
          modules = modules ++ [
            ./hardware/${name}.nix
            {
              environment.systemPackages = [ (mkSwitch name) ];
              networking.hostName = "stanbot-nix";
            }
          ];
        };

      # Headscale server config
      serverDomain = "tail.leo.camp";
      headscaleServerModules = [
        inputs.disko.nixosModules.disko
        inputs.headscale.nixosModules.default
        ./hosts/main-vps.nix
      ];

    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { config, ... }:
      let
        modules = config.flake.nixosModules;
        common = [
          inputs.determinate.nixosModules.default
          inputs.home-manager.nixosModules.default
          inputs.nix-index-database.nixosModules.nix-index
          modules.system
          modules.shell
          modules.packages
          modules.bin
          modules.desktop
          modules.games
        ];
      in
      {
        systems = [ system ];
        imports = lib.fileset.toList ./modules;

        perSystem =
          { system, ... }:
          {
            apps = {
              colmena.program = inputs.colmena.packages.${system}.colmena;
              nixos-anywhere.program = inputs.nixos-anywhere.packages.${system}.nixos-anywhere;
            };
          };

        flake = {
          nixosConfigurations = {
            desktop = mkHost "desktop" common;
            zenbook = mkHost "zenbook" common;

            # nix run .#nixos-anywhere -- --flake .#headscale-server --target-host root@tail.leo.camp
            headscale-server = lib.nixosSystem {
              inherit pkgs;
              modules = headscaleServerModules ++ [
                {
                  services.headscale-server.domain = serverDomain;
                }
              ];
            };
          };

          formatter.x86_64-linux = pkgs.nixfmt-tree.override {
            settings.formatter.nixfmt.excludes = [ "*bin.nix" ];
          };

          # nix run .#colmena -- apply --on headscale-server
          colmenaHive = inputs.colmena.lib.makeHive {
            meta.nixpkgs = pkgs;
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
    );
}
