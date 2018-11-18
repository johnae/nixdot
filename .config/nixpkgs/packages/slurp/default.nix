{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, wayland,
  wayland-protocols, cairo, libjpeg, git, systemd
}:

stdenv.mkDerivation rec {
  name = "slurp-${version}";
  version = "15b9fe5ade241ab4fbe2702007698425a516b66f";

  src = fetchFromGitHub {
    owner = "emersion";
    repo = "slurp";
    rev = version;
    sha256 = "1jlwagsjmsi9lfh038yp6d6824szhyx63yc9vbl4psxvpar94bhi";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig git
  ];
  buildInputs = [
    wayland wayland-protocols cairo libjpeg systemd
  ];

  meta = with stdenv.lib; {
    description = "select a region in a wayland compositor";
    homepage    = https://wayland.emersion.fr/slurp/;
    license     = licenses.mit;
    platforms   = platforms.linux;
  };
}