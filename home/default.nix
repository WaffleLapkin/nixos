{ params, inputs, ... }:
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

  niri = {
    enable = true;
    noctalia = true;
    laptop = true;
    touchpad = { };
    debug = { };
    wallpaper = (inputs.self + /media/pink_square.qoi);
    pfp = (inputs.self + /media/pink_square.qoi);

    binds = {
      "F6".action.screenshot = { };
    };
  };
}
