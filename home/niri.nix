{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  cfg = config.niri;

  matugenSchemeType = "scheme-tonal-spot";

  noctalia =
    cmd:
    [
      "noctalia-shell"
      "ipc"
      "call"
    ]
    ++ (pkgs.lib.splitString " " cmd);

  battery = if cfg.laptop then [ { id = "Battery"; } ] else [ ];
in
{
  options = {
    niri = {
      laptop = lib.mkEnableOption "Enable laptop specific settings";

      wallpaper = lib.mkOption {
        type = lib.types.path;
        description = "Wallpaper to use";
      };

      pfp = lib.mkOption {
        type = lib.types.path;
        description = "Profile picture to use";
      };

      enable = lib.mkEnableOption "niri";

      binds = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        description = "Additional niri keybindings";
        default = { };
      };

      touchpad = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        description = "Additional touchpad settings";
        default = { };
      };

      outputs = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        description = "Outputs settings";
        default = { };
      };

      spawn-at-startup = lib.mkOption {
        type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
        description = "SH files to start at startup";
        default = [ ];
      };

      animations = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        description = "Animation settings";
        default = { };
      };

      debug = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        description = "Debug settings";
        default = { };
      };

      switch-events = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        description = "Lid switch events";
        default = { };
      };
    };
  };

  imports = [
    inputs.niri.homeModules.niri
    inputs.matugen.nixosModules.default
    inputs.noctalia.homeModules.default
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
      brightnessctl # brightness
      playerctl # play next/prev
      gcr_4 # system prompter
      nautilus # file manager
      polkit_gnome

      xwayland-satellite # xwayland support

      matugen
      # gsettings
      glib
      dconf
      gsettings-desktop-schemas
      # gtk
      nwg-look
      # qt config tool
      kdePackages.qt6ct
      # cursors
      pkgs.google-cursor

      # # gtk
      # nwg-look
      # # qt config tool
      # kdePackages.qt6ct

      # # media control
      # playerctl
      # # brightness control
      # brightnessctl
      # pavucontrol

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
          # middle-emulation = true;
        };

        workspace-auto-back-and-forth = true;
      };

      # FIXME: doesn't seem to work?..
      gestures.hot-corners.enable = false;

      layout = {
        gaps = 8;
        center-focused-column = "never";
        always-center-single-column = true;

        preset-column-widths = [
          { proportion = 0.33333; }
          { proportion = 0.5; }
          { proportion = 0.66667; }
          { proportion = 1.0; }
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

        focus-ring = {
          width = 1;
          active.color = config.programs.matugen.theme.colors.primary.default.color;
          inactive.color = config.programs.matugen.theme.colors.surface.default.color;
          urgent.color = config.programs.matugen.theme.colors.error.default.color;
        };

        border = {
          active.color = config.programs.matugen.theme.colors.primary.default.color;
          inactive.color = config.programs.matugen.theme.colors.surface.default.color;
          urgent.color = config.programs.matugen.theme.colors.error.default.color;
        };

        shadow = {
          color = "${config.programs.matugen.theme.colors.shadow.default.color}70";
        };

        tab-indicator = {
          active.color = config.programs.matugen.theme.colors.primary.default.color;
          inactive.color = config.programs.matugen.theme.colors.primary_container.default.color;
          urgent.color = config.programs.matugen.theme.colors.error.default.color;
        };

        insert-hint = {
          display.color = "${config.programs.matugen.theme.colors.primary.default.color}80";
        };
      };

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
          matches = [ { app-id = "^firefox$"; } ];
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
            {
              app-id = "firefox$";
              title = "^Picture-in-Picture$";
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
            { app-id = "signal"; } # TODO
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
        { argv = [ "firefox" ]; }
        { argv = [ "discord" ]; }
        { argv = [ "Telegram" ]; }
        {
          argv = [
            "signal-desktop"
            "--password-store=\"kwallet6\"" # signal, I beg, allow us to change password stores :sob:
          ];
        }
      ]
      ++ cfg.spawn-at-startup;

      animations = cfg.animations;
      outputs = cfg.outputs;
      debug = cfg.debug;
      switch-events = cfg.switch-events;

      binds = {
        "Mod+Shift+Slash".action.show-hotkey-overlay = { };

        "Mod+T" = {
          hotkey-overlay.title = "Open a Terminal";
          action.spawn = "alacritty";
        };

        "Mod+P" = {
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
            "set"
            "+10%"
          ];
        };
        "XF86MonBrightnessDown" = {
          allow-when-locked = true;
          action.spawn = [
            "brightnessctl"
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

    home.pointerCursor = {
      name = "GoogleDot-Black";
      package = pkgs.google-cursor;

      gtk.enable = true;
      x11.enable = true;
      size = 24;
    };
    programs.niri.settings.cursor = {
      theme = "GoogleDot-Black";
      size = 24;
    };

    home.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt6ct";
    };

    niri.switch-events = {
      lid-close.action.spawn = noctalia "lockScreen lock";
    };

    niri.binds = {
      "Ctrl+Alt+Delete" = {
        hotkey-overlay.title = "Power menu";
        action.spawn = noctalia "sessionMenu toggle";
      };

      "Mod+D" = {
        hotkey-overlay.title = "Run an Application";
        action.spawn = noctalia "launcher toggle";
      };

      "Mod+L" = {
        hotkey-overlay.title = "Lock the Screen";
        action.spawn = noctalia "lockScreen lock";
      };

      "Mod+T" = {
        action.spawn = "alacritty";
      };

      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action.spawn = noctalia "volume increase";
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action.spawn = noctalia "volume decrease";
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action.spawn = noctalia "volume muteOutput";
      };
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action.spawn = noctalia "volume muteInput";
      };
    };

    niri.animations = { };

    niri.spawn-at-startup = [
      { argv = [ "noctalia-shell" ]; }
    ];

    programs.noctalia-shell = {
      enable = true;
      systemd.enable = false;
      settings = {
        general = {
          avatarImage = cfg.pfp;
        };
        colorSchemes = {
          darkMode = true;
          generateTemplatesForPredefined = true;
          matugenSchemeType = matugenSchemeType;
          predefinedScheme = "Noctalia (default)";
          useWallpaperColors = true;
        };
        location = {
          monthBeforeDay = false;
          name = "Delft, Netherlands";
          firstDayOfWeek = 1;
        };
        wallpaper = {
          enabled = true;
          setWallpaperOnAllMonitors = true;
          fillMode = "crop";
        };
        appLauncher = {
          enableClipboardHistory = true;
          terminalCommand = "alacritty -e";
        };
        sessionMenu = {
          enableCountdown = true;
          countdownDuration = 5000;
        };
        controlCenter = {
          position = "close_to_bar_button";
          shortcuts = {
            left = [
              {
                id = "WiFi";
              }
              {
                id = "Bluetooth";
              }
              {
                id = "PowerProfile";
              }
              {
                id = "KeepAwake";
              }
            ];
            right = [ ];
          };
        };
        bar = {
          density = "compact";
          position = "right";
          backgroundOpacity = 0.5;
          widgets = {
            left = [
              {
                id = "ControlCenter";
                useDistroLogo = true;
              }
              {
                id = "NotificationHistory";
              }
              {
                id = "plugin:catwalk";
              }
              {
                id = "Volume";
              }
            ];
            center = [
              {
                hideUnoccupied = false;
                id = "Workspace";
                labelMode = "none";
              }
            ];
            right = [
              {
                id = "Tray";
                drawerEnabled = false;
              }
              {
                id = "WiFi";
              }
              {
                id = "Bluetooth";
              }
            ]
            ++ battery
            ++ [
              {
                id = "KeyboardLayout";
                displayMode = "forceOpen";
              }
              {
                formatHorizontal = "HH:mm";
                formatVertical = "HH mm";
                id = "Clock";
                useMonospacedFont = true;
                usePrimaryColor = true;
              }
            ];
          };
        };
        templates = {
          gtk = true;
          qt = true;
          niri = true;
        };
      };
    };

    home.file.".cache/noctalia/wallpapers.json" = {
      text = builtins.toJSON {
        defaultWallpaper = cfg.wallpaper;
      };
    };

    # noctalia copies r--r--r-- for some reason
    # and fails to apply the wallpaper colors then
    home.activation.themeFiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ${config.xdg.configHome}/gtk-4.0
      mkdir -p ${config.xdg.configHome}/gtk-3.0
      mkdir -p ${config.xdg.configHome}/qt5ct/colors
      mkdir -p ${config.xdg.configHome}/qt6ct/colors

      touch ${config.xdg.configHome}/gtk-4.0/gtk.css
      touch ${config.xdg.configHome}/gtk-3.0/gtk.css
      touch ${config.xdg.configHome}/qt5ct/colors/noctalia.conf
      touch ${config.xdg.configHome}/qt6ct/colors/noctalia.conf
    '';

    programs.matugen = {
      enable = true;
      wallpaper = cfg.wallpaper;
      type = matugenSchemeType;
    };
  };
}
