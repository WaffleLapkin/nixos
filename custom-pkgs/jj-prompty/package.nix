{
  pkgs ? import <nixpkgs> { },
  lib,
}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "jj-prompty";
  version = "0.1.1";

  src = pkgs.fetchFromGitHub {
    owner = "WaffleLapkin";
    repo = pname;
    rev = "ddd0897816c3b61e3aa19a33ba6af77b5119c803";
    hash = "sha256-djBW/zDu65HA1vT5VPjqnJ8e8Ousg4vZeV2DoKsaNys=";
  };

  cargoHash = "sha256-PCUKrb/JA+KSEw1+E2A+4QDo3SZgHamPh3yu28Wv53s=";

  meta = {
    description = "";
    homepage = "https://github.com/WaffleLapkin/jj-prompty";
    license = lib.licenses.blueOak100;
    mainProgram = pname;
  };
}
