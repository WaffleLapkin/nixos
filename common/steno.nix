{
  inputs,
  pkgs,
  ...
}:
let
  plover = inputs.plover-flake.packages.${pkgs.system}.plover;
  plugins = (
    plugins: [
      # plugins.plover-machine-hid # isn't present anymore?..
      plugins.plover-python-dictionary
      (plugins.plover-stenotype-extended.overrideAttrs (oa: {
        # Patch the extended stenotype plugin, as described in <https://feather-steno.carrd.co/#getting-started>
        patches = oa.patches or [ ] ++ [ ./feather_stenotype.diff ];
      }))
    ]
  );
in
{
  environment.systemPackages = [
    pkgs.qt5.qtwayland # removes a warning from plover
    (plover.withPlugins plugins)
  ];

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = [
      pkgs.fcitx5-mozc
      pkgs.fcitx5-gtk
    ];
  };
}
