{ inputs, ... }:
{
  imports = [
    ./hardware.nix
    inputs.nixos-hardware.nixosModules.asus-flow-gv302x-amdgpu
    inputs.nixos-hardware.nixosModules.asus-flow-gv302x-nvidia
  ];

  nixpkgs.config.allowUnfree = true; # we want drivers lol

  boot.kernelParams = [
    # disables the watchdogs so that I can actually turn off the laptop normally lol :|
    "nowatchdog"
    "modprobe.blacklist=sp5100_tco,iTCO_wdt,edac_mce_amd"
  ];

  boot.initrd.luks.devices.nixos-enc = {
    device = "/dev/nvme0n1p2";
    preLVM = true;
  };

  fileSystems."/boot".options = [ "umask=0077" ];

  # In theory this allows me to change asus weird stuff
  # (in practice it doesn't)
  # services.asusd = {
  #   enable = true;
  #   enableUserService = true;
  # };

  environment.systemPackages = [
    # pkgs.asusctl
  ];

  # auto rotate screen?
  # (I don't think this works... monitor-sensor reports correct stuff but KDE does not care)
  hardware.sensor.iio.enable = true;

  services.tlp.enable = false;
  services.power-profiles-daemon.enable = true; # conflicts with tlp

  # DE
  services.desktopManager.plasma6.enable = true;
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };
  services.displayManager = {
    gdm.enable = true;
    gdm.wayland = true;
  };
  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # try to run electron apps with ozone so they scale normally

  # Local snapshots (time machine)
  # <https://github.com/digint/btrbk?tab=readme-ov-file#example-local-regular-snapshots-time-machine>
  # Thttps://github.com/GoldsteinE/nixos/blob/75fa9409534ac5e2a95ec7e5ed6804fe1b2e476e/modules/desktop/btrbk.nix>
  services.btrbk.instances.local.settings = {
    volume."/" = {
      snapshot_dir = "btrbk_snapshots";
      snapshot_preserve_min = "1w";
      snapshot_preserve = "4w";
      subvolume = {
        etc = { };
        home = { };
      };
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment? No.
}
