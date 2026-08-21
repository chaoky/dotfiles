{
  flake.nixosModules.dotfiles =
    { lib, username, ... }:
    let
      # Overrides the default ~/.config destination
      targets = {
        ssh = ".ssh";
        claude = null;
      };

      entries = lib.attrNames (builtins.readDir ../config);
      split = lib.partition (name: !(targets ? ${name})) entries;
    in
    {
      home-manager.users.${username} =
        { config, ... }:
        let
          live = name: {
            source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/config/${name}";
          };
        in
        {
          xdg.configFile = lib.genAttrs split.right live;

          home.file = lib.listToAttrs
            (
              map (name: lib.nameValuePair targets.${name} (live name)) (
                lib.filter (name: targets.${name} != null) split.wrong
              )
            ) // {
            ".claude/statusline.sh" = live "claude/statusline.sh";
            ".claudep/statusline.sh" = live "claude/statusline.sh";
          };
        };
    };
}
