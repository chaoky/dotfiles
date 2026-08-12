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

      entries = lib.attrNames (builtins.readDir ../config);
      # right: plain ~/.config/<name>, handled by xdg.configFile.
      # wrong: overridden destinations, which need home-relative paths.
      split = lib.partition (name: !(targets ? ${name})) entries;
    in
    {
      home-manager.users.leo =
        { config, ... }:
        let
          # Symlinks point at the live working tree, not the store copy, so edits
          # under config/ take effect without a rebuild.
          live = name: {
            source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/${name}";
          };
        in
        {
          xdg.configFile = lib.genAttrs split.right live;

          home.file = lib.listToAttrs (
            map (name: lib.nameValuePair targets.${name} (live name)) (
              lib.filter (name: targets.${name} != null) split.wrong
            )
          );
        };
    };
}
