# ip -j a | jq '.[] | select(.operstate=="UP") | .addr_info | .[] | select(.family=="inet") | .local' -r
{
  config,
  pkgs,
  ...
}:
{
  systemd.user.services = {
    spaceship-ddns = {
      enable = true;
      after = [ "network-online.target" ];
      wantedBy = [ "network-online.target" ];
      description = "Simple Spaceship DNS DDNS client";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writeShellScript "start-ds4ud" "${pkgs.ds4u}/bin/ds4u --daemon"}";
        Restart = "on-failure";
        RestartSec = "3";
      };
    };
  };
}
