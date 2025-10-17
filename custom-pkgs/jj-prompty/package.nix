{
  pkgs ? import <nixpkgs> { },
  lib,
}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "jj-prompty";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "WaffleLapkin";
    repo = pname;
    rev = "c15549fb655f491328a10a5fc8b944252ec24ea2";
    hash = "sha256-LpUomKFG66XYgyZO6kVsdPMBDfCBAC5B1Dqr9evbTtg=";
  };

  cargoHash = "sha256-PCUKrb/JA+KSEw1+E2A+4QDo3SZgHamPh3yu28Wv53s=";

  meta = {
    description = "";
    homepage = "https://github.com/WaffleLapkin/jj-prompty";
    license = lib.licenses.blueOak100;
  };
}
