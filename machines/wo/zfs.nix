{ lib, pkgs, ... }:
{
  networking.hostId = "b0224491";
  boot.zfs.extraPools = [ "zpool" ];
  services.zfs.autoScrub.enable = true;

  boot.kernelPackages = lib.mkForce pkgs.zfs.latestCompatibleLinuxPackages;
}
