{ stdenv, buildGoPackage, fetchgit, fetchhg, fetchbzr, fetchsvn }:

buildGoPackage rec {
  name = "persway-unstable-${version}";
  version = "2018-10-08";
  rev = "4e690623e69dba03293d7edfe7e45bbf4fe9440c";

  goPackagePath = "github.com/johnae/persway";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/johnae/persway";
    sha256 = "1spddqc3vqrf7zd33kngaxaf10wfibvw7rh2cinz8lssibi7nwmh";
  };

  goDeps = ./deps.nix;

  meta = {
    description = "Small ipc daemon for the sway wayland compositor";
    homePage = "https://github.com/johnae/persway";
  };
}
