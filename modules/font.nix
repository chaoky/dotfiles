{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs;
with lib;

let
  cfg = config.local.font;
in
{
  options.local.font = {
    enable = mkEnableOption "font module";
  };
  config = mkIf cfg.enable {
    fonts.fontconfig = {
      enable = true;
      defaultFonts.monospace = [ "Iosevka Nerd Font Mono" ];
      defaultFonts.serif = [ "FreeSerif" ];
      defaultFonts.sansSerif = [ "Fira Sans" ];
    };
    home.packages = [
      nerd-fonts.iosevka
      nerd-fonts.symbols-only
    ];
  };
}
