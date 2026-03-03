{
  flake.nixosModules.packages =
    { pkgs, ... }:
    {
      # System programs
      programs._1password-gui.enable = true;
      programs._1password.enable = true;

      programs.obs-studio = {
        enable = true;
        enableVirtualCamera = true;
        plugins = with pkgs.obs-studio-plugins; [
          obs-vaapi
        ];
      };

      services.flatpak.enable = true;
      services.printing.enable = true;
      services.ratbagd.enable = true;
      environment.systemPackages = [ pkgs.piper ];
      programs.nix-index-database.comma.enable = true;

      # Docker
      virtualisation.docker.enable = true;
      users.users.leo.extraGroups = [ "docker" ];

      # Nix-ld
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc.lib
          openssl
        ];
      };

      home-manager.users.leo =
        { config, ... }:
        {
          programs.git = {
            enable = true;
            settings = {
              user.email = "levimanga@gmail.com";
              user.name = "chaoky";
              push.autoSetupRemote = true;
            };
          };

          programs.jujutsu = {
            enable = true;
            settings = {
              user.email = "levimanga@gmail.com";
              user.name = "chaoky";
            };
          };

          programs.difftastic = {
            enable = true;
            git = {
              enable = true;
              diffToolMode = true;
            };
          };

          programs.neovim = {
            enable = true;
            defaultEditor = true;
          };

          programs.vicinae.enable = true;

          home.file = {
            ".config/doom".source = config.lib.file.mkOutOfStoreSymlink "/home/leo/dotfiles/config/doom";
            ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/leo/dotfiles/config/nvim";
            ".config/tmux".source = config.lib.file.mkOutOfStoreSymlink "/home/leo/dotfiles/config/tmux";
            ".config/ghostty".source = config.lib.file.mkOutOfStoreSymlink "/home/leo/dotfiles/config/ghostty";
            ".config/helix".source = config.lib.file.mkOutOfStoreSymlink "/home/leo/dotfiles/config/helix";
            ".config/wezterm".source = config.lib.file.mkOutOfStoreSymlink "/home/leo/dotfiles/config/wezterm";
            ".ssh".source = config.lib.file.mkOutOfStoreSymlink "/home/leo/dotfiles/config/ssh";
            ".wakatime.cfg2" = {
              text = ''
                [settings]
                api_url=https://waka.leo.camp/api
                api_key=????
              '';
            };
          };
        };
    };
}
