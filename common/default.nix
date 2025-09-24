{ pkgs, params, ... }:
{
  imports = [
    ./locale.nix
    ./friends.nix
  ];

  nix.settings.warn-dirty = false;

  users = {
    defaultUserShell = pkgs.fish;
    users.${params.username} = {
      isNormalUser = true;
      description = params.name;
      extraGroups = [
        # Enable sudo for the user.
        "wheel"
        # Allow configuring network stuff (this might be unnecessary)
        "networkmanager"
        # To be able to interact with probes
        "plugdev"
        # shark :3
        "wireshark"
      ];
      packages = [ ];
    };
  };
}
