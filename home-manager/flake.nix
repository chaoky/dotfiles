{
  description = "Home Manager configuration";

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

  outputs = { self, nixpkgs, home-manager, discord }:
    let
     system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [ discord.overlay ];
      };
      init = pkgs.writeShellScriptBin "init" ''
        export NIXPKGS_ALLOW_UNFREE=1
        {
          echo "experimental-features = nix-command flakes impure-derivations"
          echo "substituters = https://cache.nixos.org https://nix-community.cachix.org"
        } > ~/.config/nix/nix.conf
        GIT_ROOT="$(git rev-parse --show-toplevel)"
        ${pkgs.home-manager}/bin/home-manager -b backup init --switch $GIT_ROOT/home-manager
      '';
    in
    {
      homeConfigurations = {
        chaoky = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home.nix { wsl = true; } ];
        };
      };
      apps.${system}.default = {
        type = "app";
        program = "${init}/bin/init";
      };
      nixosConfigurations.default = nixpkgs.lib.nixosSystem {
        inherit pkgs system;
        modules = [ home-manager.nixosModules.default ./configuration.nix ];
      };
    };
}
