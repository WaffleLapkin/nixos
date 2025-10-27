{
  pkgs ? import <nixpkgs> { },
  lib,
}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "jj-prompty";
  version = "0.1.2";

  src = pkgs.fetchFromGitHub {
    owner = "WaffleLapkin";
    repo = pname;
    rev = "8edce9b8768686207c77d039d777b2edce49b2de";
    hash = "sha256-Pnu+dbbiwlGKjhBaMYa5drNUf7yglSZvYsqNND+SdAg=";
  };

  cargoHash = "sha256-kL02GvE+RsJJ/uP5p9t9oaVNF/tMXl1G4rdmzl8Nqig=";

  meta = {
    description = "";
    homepage = "https://github.com/WaffleLapkin/jj-prompty";
    license = lib.licenses.blueOak100;
    mainProgram = pname;
  };
}
