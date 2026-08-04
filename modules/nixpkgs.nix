{ inputs, ... }:
{
  systems = [ "x86_64-linux" ];

  perSystem = { system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      config.permittedInsecurePackages = [ "electron-39.8.10" ];
    };
    _module.args.unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
      config.permittedInsecurePackages = [ "electron-39.8.10" ];
    };
  };
}
