{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nixpkgs_plover.url = "github:FirelightFlagboy/nixpkgs/update-plover-4.0.0.dev12";
    plover-flake.url = "github:dnaq/plover-flake";
    fenix.url = "github:nix-community/fenix";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    helix.url = "github:helix-editor/helix";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      treefmt-nix,
      systems,
      ...
    }:
    let
      # Small tool to iterate over each systems (<https://github.com/numtide/treefmt-nix?tab=readme-ov-file#flakes>)
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      # Eval the treefmt modules from ./treefmt.nix
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

      mkNixosConfiguration =
        hostname:
        params@{ system, ... }:
        let
          specialArgs = {
            inherit hostname;
            inherit inputs;
            pkgs-unstable = inputs.nixpkgs.legacyPackages.${system};
            params = (import ./params.nix) // params;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./common
            ./machines/${hostname}
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = specialArgs;

              home-manager.users."${specialArgs.params.username}" = import ./home;
            }

          ];
          inherit specialArgs;
        };

      machines = {
        polaris = {
          system = "x86_64-linux";
          friends = true;
        };
        # wandering omen
        wo = {
          system = "x86_64-linux";
          friends = true;
        };
      };
    in
    {
      # for `nix fmt`
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      # for `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });

      nixosConfigurations = builtins.mapAttrs mkNixosConfiguration machines;
    };
}
