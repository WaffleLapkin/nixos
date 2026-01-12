{ lib, pkgs, ... }:
{
  networking.hostId = "abc14d5c";
  boot.zfs.extraPools = [ "zpool" ];
  services.zfs.autoScrub.enable = true;

  boot.kernelPackages = lib.mkForce pkgs.zfs.latestCompatibleLinuxPackages;
}
