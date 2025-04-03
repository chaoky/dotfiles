{
  description = "My Computers and Stuff";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
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
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      zen-browser,
      lix-module,
    }:
    let
      system = "x86_64-linux";
      zen-overlay = final: _: { zen-browser = zen-browser.packages."${system}"; };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ zen-overlay  ];
      };
      switch = pkgs.writeShellScriptBin "switch" ''
        ${pkgs.home-manager}/bin/home-manager switch -b backup --flake ~/dotfiles
      '';
    in
    {
      formatter.${system} = pkgs.nixfmt-rfc-style;
      apps.${system}.switch = {
        type = "app";
        program = "${switch}/bin/switch";
      };

      homeConfigurations.leo = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home/home.nix
          { wsl = true; }
        ];
      };

      nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
        inherit pkgs system;
        modules = [
          home-manager.nixosModules.default
          ./os/hardware-laptop.nix.nix
          ./os/configuration.nix
        ];
      };

      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit pkgs system;
        modules = [
          lix-module.nixosModules.default
          home-manager.nixosModules.default
          ./os/hardware-desktop.nix
          ./os/configuration.nix
        ];
      };

    };
}
