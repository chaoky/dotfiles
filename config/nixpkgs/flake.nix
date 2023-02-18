{
  description = "Home Manager configuration of lordie";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, emacs, ... }: {
    homeConfigurations = {
      lordie = home-manager.lib.homeManagerConfiguration {
        system = "x86_64-linux";
        homeDirectory = "/home/lordie";
        username = "lordie";
        stateVersion = "22.11";
        configuration = {
          imports = [ ./home.nix ];
          nixpkgs = {
            overlays = [emacs.overlay];
            config.allowUnfree = true;
          };
        };
      };
    };
  };
}
