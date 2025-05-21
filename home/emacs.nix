{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs;
with lib;
let
  cfg = config.local.emacs;
in
{
  options.local.emacs = {
    enable = mkEnableOption "emacs module";
  };
  config = mkIf cfg.enable {
    programs.emacs = {
      enable = true;
      extraPackages =
        epkgs: with epkgs; [
          vterm
          treesit-grammars.with-all-grammars
        ];
    };
  };
}
