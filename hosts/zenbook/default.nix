{ config, ... }:
{
  flake.nixosConfigurations.zenbook = config.flake.lib.mkHost {
    name = "zenbook";
    system = "x86_64-linux";
    hardware = ./_hardware.nix;
  };
}
