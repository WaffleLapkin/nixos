{
  inputs,
  pkgs,
  ...
}:
let
  plover = inputs.plover-flake.packages.${pkgs.system}.plover;
  plugins = (
    plugins: [
      plugins.plover-machine-hid
    ]
  );
in
{
  environment.systemPackages = [
    pkgs.qt5.qtwayland # removes a warning from plover
    (plover.withPlugins plugins)
  ];
}
