{ config, ... }:
{
  flake.nixosConfigurations.desktop = config.flake.lib.mkHost {
    name = "desktop";
    system = "x86_64-linux";
    hardware = ./_hardware.nix;
  };
}
