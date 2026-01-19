{
  config,
  lib,
  pkgs,
  ...
}:
with pkgs;
with lib;
let
  cfg = config.local.packages;
in
{
  options.local.packages = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable packages module";
    };
    emacs = mkEnableOption "emacs";
  };

  config = mkIf cfg.enable {
    # System programs
    programs._1password-gui.enable = true;
    programs._1password.enable = true;

    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = with obs-studio-plugins; [
        obs-vaapi
      ];
    };

    services.flatpak.enable = true;
    services.printing.enable = true;
    programs.nix-index-database.comma.enable = true;

    # Docker
    virtualisation.docker.enable = true;
    users.users.leo.extraGroups = [ "docker" ];

    # Nix-ld
    programs.nix-ld = {
      enable = true;
      libraries = [ stdenv.cc.cc.lib ];
    };

    home-manager.users.leo =
      { config, ... }:
      {
        programs.git = {
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

        # Emacs (optional)
        programs.emacs = mkIf cfg.emacs {
          enable = true;
          extraPackages =
            epkgs: with epkgs; [
              vterm
              treesit-grammars.with-all-grammars
            ];
        };

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
