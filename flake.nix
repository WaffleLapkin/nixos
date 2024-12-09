{
  inputs = {
    # FIXME: unpin nixpkgs, once nvidia drivers work on unstable again
    #nixpkgs.url = "github:NixOs/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:NixOs/nixpkgs/ed2a1f9299cb6f3070c4468e03c989c4a558d4bf";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs_olympus.url = "github:Petingoso/nixpkgs/olympus";
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
    in
    {
      # for `nix fmt`
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      # for `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });
      # for `nix run .#fmt` # I could not figure out what to write in `program = ` :(
      #apps = eachSystem (pkgs: {
      #  fmt = {
      #    type = "app";
      #    program = "treefmt";
      #  };
      #});
      nixosConfigurations.polaris = nixpkgs.lib.nixosSystem {
        modules = [ ./configuration.nix ];
        specialArgs = {
          inherit inputs;
        };
      };
    };
}
