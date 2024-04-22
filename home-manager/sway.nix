{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.local.sway;
in
{
  options.local.sway = { enable = mkEnableOption "sway module"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      alacritty
      wl-clipboard
    ];
    wayland.windowManager.sway = {
      enable = true;
      config = {
        modifier = "Mod4";
        terminal = "alacritty";
        startup = [
          { command = "microsoft-edge"; }
        ];
        defaultWorkspace = "workspace number 1";
        bars = [{
          mode = "dock";
          hiddenState = "hide";
          position = "top";
          workspaceButtons = true;
          workspaceNumbers = true;
          statusCommand = "${pkgs.i3status}/bin/i3status";
          fonts = {
            names = [ "monospace" ];
            size = 8.0;
          };
          trayOutput = "primary";
          colors = {
            background = "#000000";
            statusline = "#ffffff";
            separator = "#666666";
            focusedWorkspace = {
              border = "#4c7899";
              background = "#285577";
              text = "#ffffff";
            };
            activeWorkspace = {
              border = "#333333";
              background = "#5f676a";
              text = "#ffffff";
            };
            inactiveWorkspace = {
              border = "#333333";
              background = "#222222";
              text = "#888888";
            };
            urgentWorkspace = {
              border = "#2f343a";
              background = "#900000";
              text = "#ffffff";
            };
            bindingMode = {
              border = "#2f343a";
              background = "#900000";
              text = "#ffffff";
            };
          };
        }];
      };
    };
  };
}
