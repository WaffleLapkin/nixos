{ ... }:
{
  imports = [
    ./locale.nix
    ./friends.nix
  ];

  nix.settings.warn-dirty = false;
}
