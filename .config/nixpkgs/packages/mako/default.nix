{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, wayland,
  wayland-protocols, dbus_libs, pango, cairo, git, systemd
}:

stdenv.mkDerivation rec {
  name = "mako-${version}";
  version = "b30c786bdf8b90807e45ec0f52b292ee147ae1ff";

  src = fetchFromGitHub {
    owner = "emersion";
    repo = "mako";
    rev = version;
    sha256 = "1dw75cdvn34kmwdgzm228zvm0apd10rw1hx1k9xbmhihzf7jg76y";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig git
  ];
  buildInputs = [
    wayland wayland-protocols dbus_libs pango cairo systemd
  ];

  meta = with stdenv.lib; {
    description = "notification daemon for Wayland";
    homepage    = https://mako-project.org/;
    license     = licenses.mit;
    platforms   = platforms.linux;
  };
}