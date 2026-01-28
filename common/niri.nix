{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.niri;
in
{
  options = {
    niri = {
      enable = lib.mkEnableOption "niri";
      exo = lib.mkEnableOption "Enable exo theming";
      plain = lib.mkEnableOption "Plain niri with waybar";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.gnome.gnome-keyring.enable = true;
      services.gvfs.enable = true;
      services.displayManager.sessionPackages = [
        inputs.niri-unstable.packages.${pkgs.stdenv.hostPlatform.system}.niri
      ];
      programs.dconf.enable = true;
    })
    (lib.mkIf cfg.exo {
      security.pam.services.hyprlock = { };
    })
    (lib.mkIf cfg.plain {
      security.pam.services.swaylock = { };
    })
  ];
}
