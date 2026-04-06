{ pkgs, ... }:
{
  # Allow running arm/riscv binaries via emulation.
  # Nice for running ui tests.
  # https://wiki.nixos.org/wiki/QEMU
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
  ];

  environment.systemPackages = [
    pkgs.qemu
    pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc
  ];
}
