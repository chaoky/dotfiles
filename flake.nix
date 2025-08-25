{
  description = "My Computers and Stuff";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://cosmic.cachix.org/"
      "https://install.determinate.systems"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      zen-browser,
      determinate,
      nix-index-database,
      ...
    }:
    let
      system = "x86_64-linux";
      zen-overlay = final: _: { zen-browser = zen-browser.packages."${system}"; };
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
        overlays = [ zen-overlay ];
      };
      switch =
        hw:
        pkgs.writeShellScriptBin "nix-switch" (
          {
            "desktop" = "sudo nixos-rebuild switch --flake ~/dotfiles#desktop --accept-flake-config";
            "laptop" = "sudo nixos-rebuild switch --flake ~/dotfiles#laptop --accept-flake-config";
            "zenbook" = "sudo nixos-rebuild switch --flake ~/dotfiles#zenbook --accept-flake-config";
            "wsl" = "${pkgs.home-manager}/bin/home-manager switch -b backup --flake ~/dotfiles";
          }
          ."${hw}"
        );
    in
    {
      formatter.${system} = pkgs.nixfmt-tree.override {
        settings.formatter.nixfmt.excludes = [ "*bin.nix" ];
      };

      homeConfigurations.leo = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home/home.nix
          {
            home.packages = [ (switch "wsl") ];
            local.bin = {
              gui = false;
              games = false;
            };
            nix.package = pkgs.nix;
          }
        ];
      };

      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        inherit pkgs system;
        modules = [
          determinate.nixosModules.default
          home-manager.nixosModules.default
          nix-index-database.nixosModules.nix-index
          ./os/hardware-laptop.nix
          ./os/configuration.nix
          {
            environment.systemPackages = [ (switch "laptop") ];
            programs.nix-index-database.comma.enable = true;
            home-manager.users.leo.local.bin = {
              gui = true;
              games = false;
            };
          }
        ];
      };

      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit pkgs system;
        modules = [
          determinate.nixosModules.default
          home-manager.nixosModules.default
          nix-index-database.nixosModules.nix-index
          ./os/hardware-desktop.nix
          ./os/configuration.nix
          {
            environment.systemPackages = [ (switch "desktop") ];
            programs.nix-index-database.comma.enable = true;
            home-manager.users.leo.local.bin = {
              gui = true;
              games = true;
            };
          }
        ];
      };
    
      nixosConfigurations.zenbook = nixpkgs.lib.nixosSystem {
        inherit pkgs system;
        modules = [
          determinate.nixosModules.default
          home-manager.nixosModules.default
          nix-index-database.nixosModules.nix-index
          ./os/hardware-zenbook.nix
          ./os/configuration.nix
          {
            environment.systemPackages = [ (switch "zenbook") ];
            programs.nix-index-database.comma.enable = true;
            home-manager.users.leo.local.bin = {
              gui = true;
              games = false;
            };
          }
        ];
      };
    };
}
