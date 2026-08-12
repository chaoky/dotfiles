{
  flake.nixosModules.packages =
    { pkgs, unstable, username, ... }:
    {
      programs._1password.enable = true;
      programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = [ username ];
      };

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
      environment.systemPackages = [
        pkgs.piper
        pkgs.lm_sensors
      ];
      programs.nix-index-database.comma.enable = true;

      # Docker
      virtualisation.docker.enable = true;
      users.users.${username}.extraGroups = [ "docker" ];

      # Nix-ld
      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc.lib
          openssl
        ];
      };

      home-manager.users.${username} =
        { ... }:
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
            sideloadInitLua = true;
            package = unstable.neovim-unwrapped;
          };

          programs.vicinae.enable = true;

          home.file = {
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
