{
  description = "Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs29-src = {
      url = "github:emacs-mirror/emacs/emacs-29";
      flake = false;
    };
    discord = {
      url = "github:InternetUnexplorer/discord-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, emacs, emacs29-src, discord, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [
          emacs.overlay
          (final : prev: {
	          emacs29 = prev.emacsGit.overrideAttrs (old : {
	            name = "emacs29";
              version = "29.0-${emacs29-src.shortRev}";
              src = emacs29-src;
	          });
	        })
          discord.overlay
        ];
      };
      nixConf = {
        package = pkgs.nix;
        settings.experimental-features = ["nix-command" "flakes"];
      };
    in
      {
        homeConfigurations = {
          lordie = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./home.nix
              {
                inherit nixConf;
              }
            ];
          };
        };
      };
}
