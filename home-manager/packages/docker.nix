{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.docker;
  docker = pkgs.docker;
in
{
  options.services.docker = {
    enable = mkEnableOption "docker module";
  };

  config = mkIf cfg.enable {
    home = {
      packages = [ docker ];
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
