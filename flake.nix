{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    fenix.url = "github:nix-community/fenix";
  };

  outputs = inputs@{ nixpkgs, chaotic, ... }: {
    nixosConfigurations.polaris = nixpkgs.lib.nixosSystem {
      modules = [ ./configuration.nix chaotic.nixosModules.default ]; 
      specialArgs = { inherit inputs; };
    };
  };
}
