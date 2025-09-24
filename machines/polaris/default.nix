{ inputs, ... }:
{
  imports = [
    ./hardware.nix
    inputs.nixos-hardware.nixosModules.asus-flow-gv302x-amdgpu
    inputs.nixos-hardware.nixosModules.asus-flow-gv302x-nvidia
  ];

  boot.kernelParams = [
    # disables the watchdogs so that I can actually turn off the laptop normally lol :|
    "nowatchdog"
    "modprobe.blacklist=sp5100_tco,iTCO_wdt,edac_mce_amd"
  ];

  # In theory this allows me to change asus weird stuff
  # (in practice it doesn't)
  # services.asusd = {
  #   enable = true;
  #   enableUserService = true;
  # };

  # auto rotate screen?
  # (I don't think this works... monitor-sensor reports correct stuff but KDE does not care)
  hardware.sensor.iio.enable = true;
}
