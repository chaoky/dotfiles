{
  perSystem = { pkgs, ... }: {
    packages.game-lock = pkgs.runCommand "gnome-shell-extension-game-lock" { } ''
      mkdir -p $out/share/gnome-shell/extensions
      cp -r ${./extension} $out/share/gnome-shell/extensions/game-lock@chaoky
    '';
  };
}
