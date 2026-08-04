{
  perSystem = { pkgs, ... }: {
    formatter = pkgs.treefmt.withConfig {
      runtimeInputs = [
        pkgs.nixpkgs-fmt
        pkgs.stylua
        pkgs.shfmt
        pkgs.taplo
      ];
      settings.formatter = {
        nixfmt = {
          command = "nixpkgs-fmt";
          includes = [ "*.nix" ];
        };
        stylua = {
          command = "stylua";
          includes = [ "*.lua" ];
        };
        shfmt = {
          command = "shfmt";
          options = [ "-w" ];
          includes = [ "*.sh" ];
        };
        taplo = {
          command = "taplo";
          options = [ "format" ];
          includes = [ "*.toml" ];
        };
      };
    };
  };
}
