{ config, inputs, withSystem, ... }:
{
  flake.lib.mkHost = { name, system, hardware }:
    withSystem system ({ pkgs, unstable, self', ... }:
      inputs.nixpkgs.lib.nixosSystem {
        specialArgs = { inherit unstable inputs self'; };
        modules = [
          inputs.nixpkgs.nixosModules.readOnlyPkgs
          inputs.determinate.nixosModules.default
          inputs.home-manager.nixosModules.default
          inputs.nix-index-database.nixosModules.nix-index
          config.flake.nixosModules.system
          config.flake.nixosModules.shell
          config.flake.nixosModules.packages
          config.flake.nixosModules.dotfiles
          config.flake.nixosModules.bin
          config.flake.nixosModules.desktop
          config.flake.nixosModules.audio
          config.flake.nixosModules.games
          hardware
          {
            networking.hostName = "stanbot-nix"; #"${name}-stanbot-nix"
            environment.systemPackages = [
              (pkgs.writeShellScriptBin "nix-switch"
                "sudo nixos-rebuild switch --flake ~/dotfiles#${name} --accept-flake-config $@")
            ];
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            nixpkgs.pkgs = pkgs;
          }
        ];
      });
}
