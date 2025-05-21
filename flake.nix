{
  description = "My Computers and Stuff";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://cosmic.cachix.org/"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
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
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-3.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      zen-browser,
      lix-module,
      nixos-cosmic,
      nix-index-database,
    }:
    let
      system = "x86_64-linux";
      zen-overlay = final: _: { zen-browser = zen-browser.packages."${system}"; };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ zen-overlay ];
      };
      switch =
        hw:
        pkgs.writeShellScriptBin "switch" (
          {
            "desktop" = "sudo nixos-rebuild switch --flake ~/dotfiles#desktop --accept-flake-config";
            "laptop" = "sudo nixos-rebuild switch --flake ~/dotfiles#laptop --accept-flake-config";
            "wsl" = "${pkgs.home-manager}/bin/home-manager switch -b backup --flake ~/dotfiles";
          }
          ."${hw}"
        );
    in
    {
      formatter.${system} = pkgs.nixfmt-tree;
      homeConfigurations.leo = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home/home.nix
          { wsl = true; }
          { home.packages = [ (switch "wsl") ]; }
        ];
      };

      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        inherit pkgs system;
        modules = [
          home-manager.nixosModules.default
          ./os/hardware-laptop.nix
          ./os/configuration.nix
          { environment.systemPackages = [ (switch "laptop") ]; }
        ];
      };

      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit pkgs system;
        modules = [
          lix-module.nixosModules.default
          home-manager.nixosModules.default
          nixos-cosmic.nixosModules.default
          ./os/hardware-desktop.nix
          ./os/configuration.nix
          { environment.systemPackages = [ (switch "desktop") ]; }
          nix-index-database.nixosModules.nix-index
          { programs.nix-index-database.comma.enable = true; }
        ];
      };

    };
}
