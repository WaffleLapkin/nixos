{
  lib,
  config,
  inputs,
  pkgs,
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
  imports = [
    inputs.matugen.nixosModules.default
    inputs.noctalia.homeModules.default
  ];

  options = {
    niri = {
      noctalia = lib.mkEnableOption "Enable Noctalia theming";
      laptop = lib.mkEnableOption "Enable laptop specific settings";

      wallpaper = lib.mkOption {
        type = lib.types.path;
        description = "Wallpaper to use";
      };
      pfp = lib.mkOption {
        type = lib.types.path;
        description = "Profile picture to use";
      };
    };
  };

  config = lib.mkIf cfg.noctalia {
    home.packages = with pkgs; [
      matugen
      # gsettings
      glib
      dconf
      gsettings-desktop-schemas
      # gtk
      nwg-look
      # qt config tool
      kdePackages.qt6ct
    ];

    home.sessionVariables = {
      QT_QPA_PLATFORMTHEME = "qt6ct";
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
        action.spawn = "rio";
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

    niri.layout = {
      focus-ring = {
        width = 1;
        active.color = "#${config.programs.matugen.theme.colors.primary.default}";
        inactive.color = "#${config.programs.matugen.theme.colors.surface.default}";
        urgent.color = "#${config.programs.matugen.theme.colors.error.default}";
      };

      border = {
        active.color = "#${config.programs.matugen.theme.colors.primary.default}";
        inactive.color = "#${config.programs.matugen.theme.colors.surface.default}";
        urgent.color = "#${config.programs.matugen.theme.colors.error.default}";
      };

      shadow = {
        color = "#${config.programs.matugen.theme.colors.shadow.default}70";
      };

      tab-indicator = {
        active.color = "#${config.programs.matugen.theme.colors.primary.default}";
        inactive.color = "#${config.programs.matugen.theme.colors.primary_container.default}";
        urgent.color = "#${config.programs.matugen.theme.colors.error.default}";
      };

      insert-hint = {
        display.color = "#${config.programs.matugen.theme.colors.primary.default}80";
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
          name = "Prague, Czechia";
          firstDayOfWeek = 1;
        };
        wallpaper = {
          enabled = true;
          setWallpaperOnAllMonitors = true;
          fillMode = "crop";
        };
        appLauncher = {
          enableClipboardHistory = true;
          terminalCommand = "rio -e";
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
