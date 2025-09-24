{ pkgs, ... }:
{
  nix.package = pkgs.lixPackageSets.stable.lix;

  nixpkgs.overlays = [
    # https://lix.systems/add-to-config/
    (final: prev: {
      inherit (final.lixPackageSets.stable)
        nixpkgs-review
        nix-eval-jobs
        nix-fast-build
        colmena
        ;
    })
  ];
}
