{ stdenv, buildGoPackage, fetchgit, fetchhg, fetchbzr, fetchsvn }:

buildGoPackage rec {
  name = "persway-unstable-${version}";
  version = "2018-10-08";
  rev = "4edc21dd1c776521c64fb3d5b1d09a2f5ef43766";

  goPackagePath = "github.com/johnae/persway";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/johnae/persway";
    sha256 = "074kh2n09vjcljczf9p8d1yqza8rd65f9r51w7a2hk4j6wbyav6m";
  };

  goDeps = ./deps.nix;

  meta = {
    description = "Small ipc daemon for the sway wayland compositor";
    homePage = "https://github.com/johnae/persway";
  };
}
