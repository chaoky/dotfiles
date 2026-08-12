{
  flake.nixosModules.dotfiles =
    { lib, ... }:
    let
      # Overrides the default ~/.config/<name> destination; null means unlinked.
      targets = {
        ssh = ".ssh";
        # Referenced by absolute path from ~/.claude{,pz}/settings.json
        claude = null;
      };

      root = "/home/leo/dotfiles/config";
      link = name: targets.${name} or ".config/${name}";
      entries = lib.filter (name: link name != null) (lib.attrNames (builtins.readDir ../config));
    in
    {
      home-manager.users.leo =
        { config, ... }:
        {
          home.file = lib.listToAttrs (
            map
              (
                name:
                lib.nameValuePair (link name) {
                  source = config.lib.file.mkOutOfStoreSymlink "${root}/${name}";
                }
              )
              entries
          );
        };
    };
}
