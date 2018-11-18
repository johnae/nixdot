{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, wayland,
  wayland-protocols, dbus_libs, pango, cairo, git, systemd
}:

stdenv.mkDerivation rec {
  name = "mako-${version}";
  version = "ce1978865935dbff1b3bf3065ff607a4178fe57b";

  src = fetchFromGitHub {
    owner = "emersion";
    repo = "mako";
    rev = version;
    sha256 = "0cw8gs3si4v4684qfsnvpr8sv45h70k6syz3yk9ns05dm7r0fnzq";
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