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

    niri-unstable.url = "github:YaLTeR/niri";
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.niri-unstable.follows = "niri-unstable";
    };
    matugen = {
      url = "github:/InioX/matugen/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
        hostname: param_overrides:
        let
          params = import ./params.nix // param_overrides;
          specialArgs = {
            inherit hostname;
            inherit inputs;
            inherit params;
          };
        in
        nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [
            ./common
            ./machines/${hostname}
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = specialArgs;
                users."${params.username}" = ./home/${hostname}.nix;
              };
            }

          ];
        };

      machines = {
        polaris = {
          friends = true;
        };
        # wandering omen
        wo = {
          friends = true;
        };
        # no significant harasment
        nsh = {
          friends = false;
          gamer = false;
        };
      };
    in
    {
      # for `nix fmt`
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper);
      # for `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.check self;
      });

      nixosConfigurations = builtins.mapAttrs mkNixosConfiguration machines;
    };
}
