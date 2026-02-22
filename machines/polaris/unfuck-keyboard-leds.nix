{ pkgs, ... }:
{
  systemd.services = {
    unfuck-keyboard-leds = {
      enable = true;
      description = "Unfucks the state of the keyboard leds by reloading hid_asus kernel module";

      unitConfig.DefaultDependencies = "no";

      before = [ "hibernate.target" ];
      wantedBy = [ "hibernate.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.kmod}/bin/modprobe -r hid_asus";
        ExecStop = "${pkgs.kmod}/bin/modprobe hid_asus";
      };
    };
  };
}
