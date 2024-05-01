{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    fenix.url = "github:nix-community/fenix";
  };

  outputs = inputs@{ nixpkgs, ... }: {
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    nixosConfigurations.polaris = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix ];
      specialArgs = { inherit inputs; };
    };
  };
}
