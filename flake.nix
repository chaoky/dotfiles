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
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      determinate,
      nix-index-database,
      ...
    }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      switch =
        hw:
        pkgs.writeShellScriptBin "nix-switch" (
          {
            "desktop" = "sudo nixos-rebuild switch --flake ~/dotfiles#desktop --accept-flake-config $@";
            "laptop" = "sudo nixos-rebuild switch --flake ~/dotfiles#laptop --accept-flake-config $@";
            "zenbook" = "sudo nixos-rebuild switch --flake ~/dotfiles#zenbook --accept-flake-config $@";
            "wsl" = "${pkgs.home-manager}/bin/home-manager switch -b backup --flake ~/dotfile $@";
          }
          ."${hw}"
        );
      modules = lib.fileset.toList ./modules;
      baseline = modules ++ [
        determinate.nixosModules.default
        home-manager.nixosModules.default
        nix-index-database.nixosModules.nix-index
      ];
    in
    {
      formatter.${system} = pkgs.nixfmt-tree.override {
        settings.formatter.nixfmt.excludes = [ "*bin.nix" ];
      };

      homeConfigurations.leo = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          {
            home.packages = [ (switch "wsl") ];
            nix.package = pkgs.nix;
          }
        ];
      };

      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        inherit pkgs system;
        modules = baseline ++ [
          ./hardware/laptop.nix
          {
            environment.systemPackages = [ (switch "laptop") ];
          }
        ];
      };

      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit pkgs system;
        modules = baseline ++ [
          ./hardware/desktop.nix
          {
            environment.systemPackages = [ (switch "desktop") ];
            local.games.enable = true;
          }
        ];
      };

      nixosConfigurations.zenbook = nixpkgs.lib.nixosSystem {
        inherit pkgs system;
        modules = baseline ++ [
          ./hardware/zenbook.nix
          {
            environment.systemPackages = [ (switch "zenbook") ];
            local.games.enable = true;
          }
        ];
      };
    };
}
