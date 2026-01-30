{ ... }:
{
  networking.hostId = "abc14d5c";
  boot.zfs.extraPools = [ "zpool" ];
  services.zfs.autoScrub.enable = true;
}
