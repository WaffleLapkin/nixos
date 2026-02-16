{
  lib,
  stdenvNoCC,
  replaceVars,
  fetchFromGitHub,
  python3,
  ttfautohint-nox,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "eb-garamond-initials";
  version = "a11b10a68bc3b55ad16e95af346453702df22b33";

  src = fetchFromGitHub {
    owner = "georgd";
    repo = "EB-Garamond-Initials";
    rev = "${finalAttrs.version}";
    hash = "sha256-HgDR7Wdld/Ryt2Dx7dySWZDlLtvQQ8DdLmC0MZnXkPY=";
  };

  nativeBuildInputs = [
    (python3.withPackages (p: [ p.fontforge ]))
    ttfautohint-nox
  ];

  patches = [
    (replaceVars ./0001-set-version-from-nix.patch { version = finalAttrs.version; })
  ];

  buildPhase = ''
    runHook preBuild
    make WEB=build EOT="" all
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 build/*.ttf  -t $out/share/fonts/truetype
    install -Dm644 build/*.otf  -t $out/share/fonts/opentype
    install -Dm644 build/*.woff -t $out/share/fonts/woff

    runHook postInstall
  '';

  meta = {
    homepage = "http://www.georgduffner.at/ebgaramond/";
    description = "Digitization of the Garamond shown on the Egenolff-Berner specimen";
    maintainers = [ ];
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
