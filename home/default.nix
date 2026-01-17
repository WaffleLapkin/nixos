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
    outputs = {
      "eDP-1" = {
        mode = {
          width = 2560;
          height = 1440;
          refresh = 165.0;
        };

        position = {
          x = 0;
          y = 0;
        };

        scale = 1.5;

        focus-at-startup = true;
      };
    };
    debug = { };
    wallpaper = (inputs.self + /media/pink_square.qoi);
    pfp = (inputs.self + /media/pink_square.qoi);
  };
}
