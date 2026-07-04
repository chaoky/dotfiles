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
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";
    nixpkgs-unstable.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    headscale = {
      url = "github:juanfont/headscale";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
    ({ config, lib, withSystem, inputs, ... }:
      {
        systems = [ "x86_64-linux" ];
        imports = lib.fileset.toList ./modules;

        perSystem =
          { system, pkgs, ... }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              config.allowUnfree = true;
              config.permittedInsecurePackages = [ "nodejs-slim-20.20.2" "electron-39.8.10" ];
            };
            _module.args.unstable = import inputs.nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
              config.permittedInsecurePackages = [ "nodejs-slim-20.20.2" "electron-39.8.10" ];
            };

            formatter = pkgs.treefmt.withConfig {
              runtimeInputs = [ pkgs.nixpkgs-fmt ];
              settings.formatter.nixfmt = {
                command = "nixpkgs-fmt";
                includes = [ "*.nix" ];
              };
            };
          };

        flake =
          let
            # Helper to create the nix-switch script for a given host
            mkSwitcher = name: pkgs: pkgs.writeShellScriptBin "nix-switch"
              "sudo nixos-rebuild switch --flake ~/dotfiles#${name} --accept-flake-config $@";

            # Create a NixOS host configuration
            mkHost = name: system:
              withSystem system ({ pkgs, unstable, ... }:
                inputs.nixpkgs.lib.nixosSystem {
                  specialArgs = { inherit unstable; };
                  modules = [
                    inputs.nixpkgs.nixosModules.readOnlyPkgs
                    inputs.determinate.nixosModules.default
                    inputs.home-manager.nixosModules.default
                    inputs.nix-index-database.nixosModules.nix-index
                    config.flake.nixosModules.system
                    config.flake.nixosModules.shell
                    config.flake.nixosModules.packages
                    config.flake.nixosModules.bin
                    config.flake.nixosModules.desktop
                    config.flake.nixosModules.audio
                    config.flake.nixosModules.games
                    ./hardware/${name}.nix
                    {
                      networking.hostName = "stanbot-nix"; #"${name}-stanbot-nix"
                      environment.systemPackages = [ (mkSwitcher name pkgs) ];
                      home-manager.useGlobalPkgs = true;
                      home-manager.useUserPackages = true;
                      nixpkgs.pkgs = pkgs;
                    }
                  ];
                }
              );
          in
          {
            nixosConfigurations = {
              desktop = mkHost "desktop" "x86_64-linux";
              zenbook = mkHost "zenbook" "x86_64-linux";
            };
          };
      }
    );
}
