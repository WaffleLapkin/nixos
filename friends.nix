# setup ~~stolen~~ borrowed from julia (the blue one),
# <https://github.com/P1n3appl3/config/blob/a5eac974ad6be0b3abb3fdda85e98b63fd5b24c2/mixins/nixos/friends.nix>.
#
# thanks julia <3
{ ... }:
let
  user = keys: {
    initialPassword = "changethis";
    extraGroups = [ "cute" ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = keys;
  };
in
{
  users.groups.cute = { };
  users.users = {
    aria =
      user [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBi5QCHIPTT6Uvq2SLxWUKxcN7RgdtrgJxVs2muVUbqe" ]
      // {
        extraGroups = [
          "cute"
          "wheel"
        ];
      };
    astra = user [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFSLIkGOL9AFQkUUAnOI0q/ceoex2B2Dh8jL6vgcZ5w5"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNl4475+3RGgggY/klXGoNv5hKWKydVxl9GIR9qvAJ1ZMwPyFJtH3xdQki47HzWa0mBcvloP4PBJmTLihoBF/ylVGNO/a9LRenaUYpfO6jlgdE1Hwo3s+YEU3+LNKlvYVl6XilULsipto3lhlLpyHZmCvQPPi5vxX/Vv9h+M806+MyWTtOCvoknXnU2wi7JOHug1eDI097ooES6Tu+90IXmm1ejDGVAzD0pERmad7OtQF/PzyUhPNasQnYLtqvDwGmMRpINXULEZuRkUEhir1ozTF8aU42ZFVF1h0DW+BVTccHMbNrPIL/z/IcZxpVEPwvxvKiBPVUFaVQiXpN85u0pk5lGegBji76lRsPntPvhL7rzNgfAXdWBNu8S4nFeJP3c2+RAcnMZrsjBiVtJwODhEFoBIVvU597KQPBIw+odYTuBEeeExu19zAHVd/U7Sfhm5DiU/oTiAvbvCi9jZkidMDy3GGBvSVhuYTPEBXg0z7VUEXVGp0AHhdd6L/yJmBpIAYA/+dqxHoLXOlOKiSpZANCpdPnmXoclAWIQB4voZeRxlQe+Ag8usHrzulKv7oMbmySXHw16yLhwYDLTEK0vKzJKaydgElVw5ypB28va4luazICGxXwZoIe5Ik84gDG5nUNAJ9Ff+GAGBS9u7gpVxPhV6dZXt3j2WMPJ0oTXQ=="
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGtisQ+vPNgDq23gRooHyBHk9U6QjTr1HFuJlN1TPivL"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBv5G3sz39vTW2Wvt2ru1+GHBSgfFNufdVMcEKe7/zV"
    ];
    julia = user [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCatP3klEjfQPSiJNUc3FRDdz927BG1IzektpouzOZR" ];
    jana = user [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIET69oniNUA2nJV5+GxQ6XuK+vQbO8Uhtgrp1TrmiXVi"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOAXOTU6E06zjK/zkzlSPhTG35PoNRYgTCStEPUYyjeE"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBTqoHEVYxD+mwmZhPj+1+i1P0XmgTxXgSnPdPwFT1vr"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjE6rvXFX5qr7JGiY7WyXqseMlxSk7M+wyvMAgjIFuD"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICgadaDrViJp0Z6fbLBAo9grkmCeNQliIPXe12l3X3i/"
    ];
    nora = user [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0n1ikUG9rYqobh7WpAyXrqZqxQoQ2zNJrFPj12gTpP" ];
    boxy = user [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKOIOhM1xy7x9XY2VBioimjDkqtZI0/paCw1zh3Wjn9Y"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFMNJco+7XH1x91n2rPkOS8Wbq0+Bv6KhWWkacN1y1DR"
    ];
    vivian = user [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA+8Uu2zJEzZYQ3XhYfuu7FZmEci+Ty9r26Z3L+v6TKV"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBhJAp7NWlHgwDYd2z6VNROy5RkeZHRINFLsFvwT4b3"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIfooZjMWXvXZu1ReOEACDZ0TMb2WJRBSOLlWE8y6fUh"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID+HbsgJTQS6pvnMEI5NPKjIf78z+9A7CTIt3abi+PS6"
    ];
    mara = user [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKAzf3UCwTWJlF878EWqlrLUOBsxw/b/6PoLjbKkA8Xh"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIHi5YnRt1VgK8tt6oSPsKo1X+0gcBXVyvCKXM03/vEh"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFWF1MtDV5HJT+GhD8wrKICyDwQK8ZPQTxZdnsfaqWcs"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIHi1EEGRry1aD6uPmdlcRqdiTiIty0JlnfoXeM0qKBC"
    ];
    jyn = user [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCq58SNpVf4jk1Vs5W7Ur4yap/9vSyuKSIo+ZmBHtMwt0sRxqlpaCm7SgxOcggyItzCRgjJd4X4fi5MNufDD8HB26YPO7fC6VJha+CccBX+y67xjGxWEJW8ERSnyD5T6Pf+g9kWQCov6IJreKS7tn0j/rH4GW9EVB+T4G7T4b6anmSz49L8AII/rYDYCYcKU+JSl6fQGrliZP12NZJCW9T5nOhqTBEQBnIrTuUeD2Jdb39jloQ4Xob3UPld63ciWWIOWPF/TL4B3ILeAAz5+yljtI0H5jXmLNkN2noOitZp+9hdD/w7gpcn6WQeQV9hQJRwNhvx0xXfZsnsqkn1Qrvd"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC51nwBzsuJaYqpIcK/F/wIGdvduedtz49G4WkuXZfgkbJ2J459cEQlCt5QQsDRG62cTeSh8fSDUX3vDsU+NuqwF5nba1vdjsCiw7SEDCFf9V8BGSR86T8FZcEyqSuaH00wCzKfLu6i4kkjG1y9nhUXLIe4EFJIxuD6ELKU7OoiJphleqDRouSuEbwNC3BL3TZRJsr7NfbA4IT/k4hBXFRZG/Aae2X77mpGigv2D3l2b7y/03AKhAjSyULpWsj/5C9ZVuEYePH8E9JsbeEXoLhfQIj2ZXzWIOsjB4oaCwD1GLkTmw7pdvYvNI/koDCKQfC3Xsl+XakmbVNPhEtNYN8skAggo+In2UTJDtejTHfv17YPbJ57S7EM3/IeOaTFRcnJkC/bAgIwSDK7YAOhrI7DpQgHDy5Fbasc98Wg6iD4zkaIZrSsUwIDVDJdNm5TQCouIIYvT7ucqv9XtYLUEyvbr/96gcTIViZec2aiR+Jd2fBr2DlqWRAA4N36OiJn1uc="
    ];
    cdruid = user [
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAGuyes0oNZO+LWvjx6JnPMth7nFwUDg4MoJs5Q00uZAEwjC+eAkk3SxAAiyORaRD250ASjJ/ArZWUQ7IZENcHBEVQGWaCWuw06Rr2f4KVNmnPzPFKpd91QxyBd3EXXScpDeOKGF/yB1GCMkNN52StVEllhiz/eorAXFo4d0bzlRxNivBg=="
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0im7/KNw4pgeH3RzgQaJeVFekbqXjDj+HYPqVbSFXv"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH8dZcQILx0u2efLceHWaXzulOsu9rHO1xeGT5SLeNWc"
    ];
    yaah = user [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBvDoWAmF3JupYvTTSSA084bPdmYWUrIlK66r9QL2JlD" ];
  };
}
