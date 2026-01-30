{ ... }:
{
  networking.hostId = "b0224491";
  boot.zfs.extraPools = [ "zpool" ];
  services.zfs.autoScrub.enable = true;
}
