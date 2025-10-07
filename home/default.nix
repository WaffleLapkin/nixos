{ params, ... }:
{
  imports = [
    ./jujutsu.nix
    ./fish.nix
    ./ssh.nix
  ];

  home.username = params.username;
  home.homeDirectory = "/home/${params.username}";

  programs.home-manager.enable = true;
  home.stateVersion = "25.11";
}
