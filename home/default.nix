{
  lib,
  params,
  inputs,
  ...
}:
{
  imports = [
    ./jujutsu.nix
    ./fish.nix
    ./ssh.nix
    ./helix.nix
    ./starship.nix
    ./niri.nix
    ./niri-noctalia.nix
  ];

  home.username = params.username;
  home.homeDirectory = "/home/${params.username}";

  programs.home-manager.enable = true;
  home.stateVersion = "25.11";

  # Supposed to help with bluetooth headphones and stuff...
  # https://wiki.nixos.org/wiki/Bluetooth#Using_Bluetooth_headset_buttons_to_control_media_player
  services.mpris-proxy.enable = true;

  niri = {
    enable = lib.mkDefault true;
    noctalia = true;
    laptop = true;
    outputs = { };
    touchpad = { };
    debug = { };
    wallpaper = (inputs.self + /media/pink_square.qoi);
    pfp = (inputs.self + /media/waffle_cat.jpg);

    binds = {
      "F6".action.screenshot = { };
    };
  };
}
