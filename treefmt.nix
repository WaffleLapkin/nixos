# <https://github.com/numtide/treefmt-nix?tab=readme-ov-file#flakes>
{ pkgs, ... }:
{
  # Used to find the project root
  projectRootFile = "flake.nix";
  programs.nixfmt-rfc-style.enable = true;
}
