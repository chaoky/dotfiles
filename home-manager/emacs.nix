{ config, lib, pkgs, ... }:
with pkgs;
with lib;
let
  cfg = config.local.emacs;
  emacs = [
    emacs29-pgtk
    emacsPackages.vterm
    #core
    (ripgrep.override {withPCRE2 = true;})
    gnutls
    fd
    imagemagick
    zstd
    fava
    pinentry-emacs
    # :tools editorconfig
    editorconfig-core-c
    # :checkers spell
    (aspellWithDicts (ds: with ds; [ en en-computers en-science ]))
    # :lang latex & :lang org (latex previews)
    texlive.combined.scheme-medium
    # :lang markdown
    pandoc
    #fonts
    emacs-all-the-icons-fonts
    iosevka-bin
  ];
in
{
  options.local.emacs = { enable = mkEnableOption "emacs module"; };
  config = mkIf cfg.enable {
    home.packages = emacs;
  };
}