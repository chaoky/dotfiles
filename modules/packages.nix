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
          obs-pipewire-audio-capture
          # nixpkgs adds the driver runpath to OBS's libs and plugins but not
          # to bin/obs-nvenc-test, so NVENC detection fails and OBS silently
          # falls back to x264. wrapOBS splices each plugin's
          # obsWrapperArguments into the launcher, so a no-op "plugin" can
          # expose the driver libs to that helper without rebuilding OBS.
          (pkgs.runCommand "obs-nvidia-driver-env" {
            passthru.obsWrapperArguments = [ "--prefix LD_LIBRARY_PATH : /run/opengl-driver/lib" ];
          } "mkdir -p $out")
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
      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
      boot.binfmt.preferStaticEmulators = true;

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
            withPython3 = false;
            withRuby = false;
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
