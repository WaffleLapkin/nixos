{ ... }:
{
  imports = [ ./. ];
  niri.outputs = {
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

  niri.binds = {
    "XF86KbdBrightnessUp" = {
      allow-when-locked = true;
      action.spawn = [
        "asusctl"
        "leds"
        "next"
      ];
    };
    "XF86KbdBrightnessDown" = {
      allow-when-locked = true;
      action.spawn = [
        "asusctl"
        "leds"
        "prev"
      ];
    };
  };
}
