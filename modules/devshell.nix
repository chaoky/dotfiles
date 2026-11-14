{
  perSystem = { pkgs, ... }:
    let
      update = name: inputs: pkgs.writeShellScriptBin name ''
        exec nix flake update --flake "$(git rev-parse --show-toplevel)" ${inputs} "$@"
      '';
    in
    {
      devShells.default = pkgs.mkShell {
        packages = [
          (update "update-pc" "nixpkgs nixpkgs-unstable home-manager zen-browser nix-index-database determinate flake-parts import-tree")
          (update "update-server" "nixpkgs-server headscale colmena disko nixos-anywhere")
        ];
      };
    };
}
