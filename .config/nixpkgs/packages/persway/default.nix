{ stdenv, buildGoPackage, fetchgit, fetchhg, fetchbzr, fetchsvn }:

buildGoPackage rec {
  name = "persway-unstable-${version}";
  version = "2018-10-08";
  rev = "57152d09d32982c84639e8761359f9ad8f71e1b7";

  goPackagePath = "github.com/johnae/persway";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/johnae/persway";
    sha256 = "0kkgkwfk8vnnkwl7bhxrzfkd60ymiwjgkwc477wv542rsr1h7h9d";
  };

  goDeps = ./deps.nix;

  meta = {
    description = "Small ipc daemon for the sway wayland compositor";
    homePage = "https://github.com/johnae/persway";
  };
}
