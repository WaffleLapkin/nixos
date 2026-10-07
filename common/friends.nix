# setup ~~stolen~~ borrowed from julia (the blue one),
# <https://github.com/P1n3appl3/config/blob/a5eac974ad6be0b3abb3fdda85e98b63fd5b24c2/mixins/nixos/friends.nix>.
#
# thanks julia <3
{ lib, params, ... }:
let
  user = keys: {
    initialPassword = "changethis";
    extraGroups = [ "cute" ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = keys;
  };
in
lib.mkIf params.friends {
  users.groups.cute = { };
  users.users = {
    julia = user [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCatP3klEjfQPSiJNUc3FRDdz927BG1IzektpouzOZR" ];
    jana = user [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIET69oniNUA2nJV5+GxQ6XuK+vQbO8Uhtgrp1TrmiXVi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOAXOTU6E06zjK/zkzlSPhTG35PoNRYgTCStEPUYyjeE"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBTqoHEVYxD+mwmZhPj+1+i1P0XmgTxXgSnPdPwFT1vr"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjE6rvXFX5qr7JGiY7WyXqseMlxSk7M+wyvMAgjIFuD"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgadaDrViJp0Z6fbLBAo9grkmCeNQliIPXe12l3X3i/"
    ];
    boxy = user [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOIOhM1xy7x9XY2VBioimjDkqtZI0/paCw1zh3Wjn9Y"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMNJco+7XH1x91n2rPkOS8Wbq0+Bv6KhWWkacN1y1DR"
    ];
    cdruid = user [
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAGuyes0oNZO+LWvjx6JnPMth7nFwUDg4MoJs5Q00uZAEwjC+eAkk3SxAAiyORaRD250ASjJ/ArZWUQ7IZENcHBEVQGWaCWuw06Rr2f4KVNmnPzPFKpd91QxyBd3EXXScpDeOKGF/yB1GCMkNN52StVEllhiz/eorAXFo4d0bzlRxNivBg=="
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0im7/KNw4pgeH3RzgQaJeVFekbqXjDj+HYPqVbSFXv"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8dZcQILx0u2efLceHWaXzulOsu9rHO1xeGT5SLeNWc"
    ];
  };
}
