{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, wayland,
  wayland-protocols, dbus_libs, pango, cairo, git, systemd
}:

stdenv.mkDerivation rec {
  name = "mako-${version}";
  version = "5c01d129bf448aad451b113dc6b76b60e10334e2";

  src = fetchFromGitHub {
    owner = "emersion";
    repo = "mako";
    rev = version;
    sha256 = "19p0abvgvncqx7dv8cssngvrij5wszplbk05i61p1qgzlxw52cp6";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig git
  ];
  buildInputs = [
    wayland wayland-protocols dbus_libs pango cairo systemd
  ];

  #enableParallelBuilding = true;

  #cmakeFlags = "-DVERSION=${version} -DLD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver-32/lib";

  meta = with stdenv.lib; {
    description = "notification daemon for Wayland";
    homepage    = https://mako-project.org/;
    license     = licenses.mit;
    platforms   = platforms.linux;
    #maintainers = with maintainers; [ johnae ]; # Trying to keep it up-to-date.
  };
}