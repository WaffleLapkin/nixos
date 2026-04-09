{ pkgs, ... }:
{
  imports = [ ./. ];
  niri.enable = false;

  programs.fish.interactiveShellInit = ''
    # without this logging in directly with fish on a non-nixos machine doesn't work :/
    source /etc/profile.d/nix-daemon.fish

    # that's where pacman puts rust-analyzer proxy: <https://gitlab.archlinux.org/archlinux/packaging/packages/rustup/-/blob/2db544a3e374b13b0001b01dc71d5785649f66ab/PKGBUILD#L54>
    fish_add_path /usr/lib/rustup/bin
  '';

  home.packages = [
    pkgs.mosh
    pkgs.ast-grep
    pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc
    pkgs.delta
  ];
}
