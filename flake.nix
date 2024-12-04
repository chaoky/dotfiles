{
  description = "My Computers and Stuff";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    discord = {
      url = "github:InternetUnexplorer/discord-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      discord,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ discord.overlay ];
      };
      init = pkgs.writeShellScriptBin "init" ''
        {
          echo "experimental-features = nix-command flakes impure-derivations"
          echo "substituters = https://cache.nixos.org https://nix-community.cachix.org"
        } > ~/.config/nix/nix.conf
        ${pkgs.home-manager}/bin/home-manager switch -b backup --flake ~/dotfiles
      '';
    in
    {
      formatter.${system} = pkgs.nixfmt-rfc-style;
      apps.${system}.switch = {
        type = "app";
        program = "${init}/bin/init";
      };

      homeConfigurations.leo = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home/home.nix
          { wsl = true; }
        ];
      };

      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit pkgs system;
        modules = [
          home-manager.nixosModules.default
          ./os/hardware.nix
          ./os/configuration.nix
        ];
      };
    };
}
