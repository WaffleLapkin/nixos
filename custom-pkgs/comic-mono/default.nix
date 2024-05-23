# Based on 
# - AUR package: <https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=ttf-comic-mono-git>
# - Fire Code nixpkgs package: <https://github.com/NixOS/nixpkgs/blob/311cd0a3d88abaafdd5b5218efd6affea48fba7e/pkgs/by-name/ct/ctx/package.nix#L3>
{
  lib,
  stdenvNoCC,
  fetchgit,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "comic-mono";
  version = "1";

  src = fetchgit {
    url = "https://github.com/dtinth/comic-mono-font.git";
    rev = "9a96d04cdd2919964169192e7d9de5012ef66de4";
    hash = "sha256-UHOwZL9WpCHk6vZaqI/XfkZogKgycs5lWg1p0XdQt0A=";
  };

  # FIXME: put the license somewhere?
  #install -Dm644 'comic-mono-font/LICENSE' -t "${pkgdir}/usr/share/licenses/${pkgname%-*}"
  installPhase = ''
        runHook preInstall

        install -Dm755 -t $out/share/fonts/truetype 'comic-mono-font/'*.ttf
    	
        runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://dtinth.github.io/comic-mono-font/";
    description = "A legible monospace font… the very typeface you’ve been trained to recognize since childhood.";
    license = licenses.mit;
    platforms = platforms.all;
  };
})
