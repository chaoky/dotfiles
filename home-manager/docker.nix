{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.local.docker;
in
{
  options.local.docker = {
    enable = mkEnableOption "docker module";
  };

  config = mkIf cfg.enable {
    home = {
      packages = [ pkgs.docker ];
      #NIX users hate him
      activation.dockerDeamon = {
        after = [ "writeBoundary" "createXdgUserDirectories" ];
        before = [ ];
        data = ''
          /usr/bin/sudo /usr/bin/systemctl enable ${docker.out}/etc/systemd/system/docker.service
          /usr/bin/sudo /usr/bin/systemctl enable ${docker.out}/etc/systemd/system/docker.socket
        '';
      };
    };
  };
}
