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
    };
  };

  config = lib.mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = true;
    services.gvfs.enable = true;
    services.displayManager.sessionPackages = [
      inputs.niri-unstable.packages.${pkgs.stdenv.hostPlatform.system}.niri
    ];
    programs.dconf.enable = true;
  };
}
