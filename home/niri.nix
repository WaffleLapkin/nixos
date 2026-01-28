{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.niri;
in
{
  options = {
    niri = {
      enable = lib.mkEnableOption "niri";

      binds = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        description = "Additional niri keybindings";
      };

      touchpad = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        description = "Additional touchpad settings";
      };

      outputs = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        description = "Outputs settings";
      };

      spawn-at-startup = lib.mkOption {
        type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
        description = "SH files to start at startup";
      };

      animations = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        description = "Animation settings";
      };

      layout = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        description = "Additional layout settings";
      };

      debug = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        description = "Debug settings";
      };
    };
  };

  imports = [
    inputs.niri.homeModules.niri
  ];

  config = lib.mkIf cfg.enable {
    programs.waybar.enable = true;
    programs.niri = {
      package = inputs.niri-unstable.packages.${pkgs.stdenv.hostPlatform.system}.niri;
      enable = true;
    };
    services.swayidle.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
    };

    home.packages = with pkgs; [
      rio # terminal
      brightnessctl # brightness
      gcr # system prompter
      nautilus # file manager
      polkit_gnome

      xwayland-satellite # xwayland support
    ];

    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "polkit-gnome-authentication-agent-1";
        Wants = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    programs.niri.settings = {
      input = {
        keyboard = {
          xkb = {
            layout = "us,ru";
            options = "grp:caps_toggle";
          };
          numlock = true;
        };

        mouse = {
          accel-speed = -0.5;
          scroll-factor = 3;
        };

        touchpad = {
          dwt = true;
          tap = true;
          tap-button-map = "left-right-middle";
          click-method = "clickfinger";
          natural-scroll = true;
        }
        // cfg.touchpad;

        trackball = {
          scroll-method = "on-button-down";
          scroll-button = 256;
        };
      };

      gestures.hot-corners.enable = false;

      layout = {
        gaps = 16;
        center-focused-column = "never";

        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
        ];

        default-column-width = {
          proportion = 0.5;
        };

        shadow = {
          softness = 20;
          spread = 5;
          offset = {
            x = 0;
            y = 5;
          };
        };
      }
      // cfg.layout;

      hotkey-overlay.skip-at-startup = true;

      screenshot-path = "~/pictures/screenshots/screenshot from %Y-%m-%d %H-%M-%S.png";

      workspaces."browser" = { };
      workspaces."chat" = { };

      window-rules = [
        {
          matches = [ { app-id = "^1Password$"; } ];
          open-floating = true;
          open-focused = true;
          block-out-from = "screen-capture";
        }

        {
          matches = [ { app-id = "microsoft-edge"; } ];
          open-on-workspace = "browser";
        }

        {
          matches = [
            {
              app-id = "org.gnome.Nautilus";
              title = "Open Files";
            }
            {
              app-id = "org.telegram.desktop";
              title = "Media viewer";
            }
            {
              app-id = "steam";
              title = "Steam Settings";
            }
          ];
          open-floating = true;
          # fullscreen windows don't float, they drown
          open-fullscreen = false;
        }

        {
          matches = [
            { app-id = "discord"; }
            {
              app-id = "org.telegram.desktop";
              title = "^(.{0,11}$|[^M]|.[^e]|..[^d]|...[^i]|.{4}[^a]|.{5}[^ ]|.{6}[^v]|.{7}[^i]|.{8}[^e]|.{9}[^w]|.{10}[^e]|.{11}[^r]|.{13,})";
            }
          ];
          open-on-workspace = "chat";
        }

        {
          geometry-corner-radius = {
            top-left = 8.0;
            top-right = 8.0;
            bottom-right = 8.0;
            bottom-left = 8.0;
          };
          clip-to-geometry = true;
        }

        {
          matches = [
            {
              app-id = "org.telegram.desktop";
              title = "Media viewer";
            }
          ];

          # focus ring kills transparency, <https://github.com/YaLTeR/niri/issues/1823>
          focus-ring = {
            enable = false;
          };

          # try to match corners of the noctalia shell
          # can possibly be superseeded by using open-maximized-to-edges,
          # once flake maintainer finds time to add it <https://github.com/sodiboo/niri-flake/issues/1493>
          geometry-corner-radius = {
            top-left = 0.0;
            top-right = 12.0;
            bottom-right = 12.0;
            bottom-left = 0.0;
          };
        }
      ];

      spawn-at-startup = [
        {
          argv = [
            "1password"
            "--silent"
          ];
        }
        { argv = [ "microsoft-edge" ]; }
        { argv = [ "discord" ]; }
        { argv = [ "Telegram" ]; }
      ]
      ++ cfg.spawn-at-startup;

      animations = cfg.animations;
      outputs = cfg.outputs;
      debug = cfg.debug;

      binds = {
        "Mod+Shift+Slash".action.show-hotkey-overlay = { };

        "Mod+T" = {
          hotkey-overlay.title = "Open a Terminal";
          action.spawn = "rio";
        };

        "Ctrl+Shift+Space" = {
          action.spawn = [
            "1password"
            "--quick-access"
          ];
        };

        "XF86AudioRaiseVolume" = {
          allow-when-locked = true;
          action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
        };
        "XF86AudioLowerVolume" = {
          allow-when-locked = true;
          action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
        };
        "XF86AudioMute" = {
          allow-when-locked = true;
          action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };
        "XF86AudioMicMute" = {
          allow-when-locked = true;
          action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        };

        "XF86AudioPlay" = {
          allow-when-locked = true;
          action.spawn-sh = "playerctl play-pause";
        };
        "XF86AudioStop" = {
          allow-when-locked = true;
          action.spawn-sh = "playerctl stop";
        };
        "XF86AudioPrev" = {
          allow-when-locked = true;
          action.spawn-sh = "playerctl previous";
        };
        "XF86AudioNext" = {
          allow-when-locked = true;
          action.spawn-sh = "playerctl next";
        };

        "XF86MonBrightnessUp" = {
          allow-when-locked = true;
          action.spawn = [
            "brightnessctl"
            "--device=amdgpu_bl1"
            "--class=backlight"
            "set"
            "+10%"
          ];
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action.spawn = [
            "brightnessctl"
            "--device=amdgpu_bl1"
            "--class=backlight"
            "set"
            "10%-"
          ];
        };

        "Mod+O" = {
          repeat = false;
          action.toggle-overview = { };
        };
        "Mod+Q" = {
          repeat = false;
          action.close-window = { };
        };

        "Mod+Left".action.focus-column-left = { };
        "Mod+Down".action.focus-window-or-workspace-down = { };
        "Mod+Up".action.focus-window-or-workspace-up = { };
        "Mod+Right".action.focus-column-right = { };

        "Mod+Ctrl+Left".action.move-column-left = { };
        "Mod+Ctrl+Down".action.move-window-down-or-to-workspace-down = { };
        "Mod+Ctrl+Up".action.move-window-up-or-to-workspace-up = { };
        "Mod+Ctrl+Right".action.move-column-right = { };

        "Mod+Home".action.focus-column-first = { };
        "Mod+End".action.focus-column-last = { };
        "Mod+Ctrl+Home".action.move-column-to-first = { };
        "Mod+Ctrl+End".action.move-column-to-last = { };

        "Mod+Shift+Left".action.focus-monitor-left = { };
        "Mod+Shift+Down".action.focus-monitor-down = { };
        "Mod+Shift+Up".action.focus-monitor-up = { };
        "Mod+Shift+Right".action.focus-monitor-right = { };

        "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = { };
        "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = { };
        "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = { };
        "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = { };

        "Mod+Shift+WheelScrollDown".action.focus-column-right = { };
        "Mod+Shift+WheelScrollUp".action.focus-column-left = { };
        "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = { };
        "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = { };

        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        "Mod+Ctrl+1".action.move-column-to-workspace = 1;
        "Mod+Ctrl+2".action.move-column-to-workspace = 2;
        "Mod+Ctrl+3".action.move-column-to-workspace = 3;
        "Mod+Ctrl+4".action.move-column-to-workspace = 4;
        "Mod+Ctrl+5".action.move-column-to-workspace = 5;
        "Mod+Ctrl+6".action.move-column-to-workspace = 6;
        "Mod+Ctrl+7".action.move-column-to-workspace = 7;
        "Mod+Ctrl+8".action.move-column-to-workspace = 8;
        "Mod+Ctrl+9".action.move-column-to-workspace = 9;

        "Mod+Page_Down".action.focus-workspace-down = { };
        "Mod+Page_Up".action.focus-workspace-up = { };
        "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = { };
        "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = { };

        "Mod+Shift+Page_Down".action.move-workspace-down = { };
        "Mod+Shift+Page_Up".action.move-workspace-up = { };

        "Mod+WheelScrollDown" = {
          cooldown-ms = 150;
          action.focus-workspace-down = { };
        };
        "Mod+WheelScrollUp" = {
          cooldown-ms = 150;
          action.focus-workspace-up = { };
        };
        "Mod+Ctrl+WheelScrollDown" = {
          cooldown-ms = 150;
          action.move-column-to-workspace-down = { };
        };
        "Mod+Ctrl+WheelScrollUp" = {
          cooldown-ms = 150;
          action.move-column-to-workspace-up = { };
        };

        "Mod+WheelScrollRight".action.focus-column-right = { };
        "Mod+WheelScrollLeft".action.focus-column-left = { };
        "Mod+Ctrl+WheelScrollRight".action.move-column-right = { };
        "Mod+Ctrl+WheelScrollLeft".action.move-column-left = { };

        "Mod+BracketLeft".action.consume-or-expel-window-left = { };
        "Mod+BracketRight".action.consume-or-expel-window-right = { };

        "Mod+Comma".action.consume-window-into-column = { };
        "Mod+Period".action.expel-window-from-column = { };

        "Mod+R".action.switch-preset-column-width = { };
        "Mod+Shift+R".action.switch-preset-window-height = { };
        "Mod+Ctrl+R".action.reset-window-height = { };
        "Mod+F".action.maximize-column = { };
        "Mod+Shift+F".action.fullscreen-window = { };

        "Mod+Ctrl+F".action.expand-column-to-available-width = { };

        "Mod+C".action.center-column = { };

        "Mod+Ctrl+C".action.center-visible-columns = { };

        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";

        "Mod+Shift+Minus".action.set-window-height = "-10%";
        "Mod+Shift+Equal".action.set-window-height = "+10%";

        "Mod+V".action.toggle-window-floating = { };
        "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = { };

        "Mod+W".action.toggle-column-tabbed-display = { };

        "Ctrl+Print".action.screenshot-screen = { };
        "Alt+Print".action.screenshot-window = { };

        "Mod+Escape" = {
          allow-inhibiting = false;
          action.toggle-keyboard-shortcuts-inhibit = { };
        };

        "Mod+Shift+E".action.quit = { };

        "Mod+Shift+P".action.power-off-monitors = { };
      }
      // cfg.binds;
    };

    dconf.settings = {
      # appearance
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
        gtk-enable-primary-paste = false;
      };
    };
  };
}
