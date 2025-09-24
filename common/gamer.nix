{
  pkgs,
  lib,
  params,
  ...
}:
lib.mkIf params.gamer {
  programs.steam = {
    enable = true;
    #remotePlay.openFirewall = true;
    #dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
    package = pkgs.steam.override {
      extraPkgs = pkgs: [
        # Needed for gamescope to work
        # <https://www.reddit.com/r/NixOS/comments/1bmj4mz/gamescope_and_steam/>
        # <https://github.com/NixOS/nixpkgs/issues/162562#issuecomment-1229444338>
        pkgs.libkrb5
        pkgs.keyutils
      ];
    };
  };

  environment.sessionVariables.STEAM_FORCE_DESKTOPUI_SCALING = "1.5"; # force steam to scale

  environment.systemPackages = [
    pkgs.r2modman
    pkgs.olympus
    pkgs.wineWowPackages.waylandFull
    pkgs.mangohud
  ];
}
