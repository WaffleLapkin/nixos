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

      "Lenovo Group Limited 0x8AB1 Unknown" = {
        mode = {
          width = 3072;
          height = 1920;
          refresh = 60.0;
        };

        position = {
          x = 0;
          y = 0;
        };

        scale = 1.5;
      };
      "LG Electronics LG ULTRAWIDE 411NTHM28193" = {
        mode = {
          width = 3440;
          height = 1440;
          refresh = 59.987; # :sob:
        };

        position = {
          x = -builtins.floor (3072 / 1.5); # 2048 !
          y = builtins.floor (1920 / 1.5 - 1440);
        };
      };
    };
    debug = { };
    wallpaper = (inputs.self + /media/pink_square.qoi);
    pfp = (inputs.self + /media/pink_square.qoi);

    binds = {
      "F6".action.screenshot = { };
    };
  };
}
