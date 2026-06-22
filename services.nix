{
  config,
  pkgs,
  ...
}:
{
  systemd.user.services = {
    ds4ud = {
      enable = true;
      after = [ "graphical-session.target" ];
      wantedBy = [ ];
      description = "DS4U DualSense Daemon";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writeShellScript "start-ds4ud" "${pkgs.ds4upin.ds4u}/bin/ds4u --daemon"};";
        Restart = "on-failure";
        RestartSec = "3";
      };
    };
  };
}
