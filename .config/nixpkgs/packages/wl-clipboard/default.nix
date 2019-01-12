{ stdenv, fetchFromGitHub, coreutils, gnused, meson, ninja, pkgconfig, wayland, wayland-protocols, git, systemd}:

stdenv.mkDerivation rec {
  name = "wl-clipboard-${version}";
  version = "1d99c3d5720a012d5a034535f703f6b290408ebf";

  src = fetchFromGitHub {
    owner = "bugaevc";
    repo = "wl-clipboard";
    rev = version;
    sha256 = "1zy5a1pwx0s1ywlh3g9g3n1j6idrq2ayxb8zl1y8yri50krsvp45";
  };

  preConfigure = ''
    echo "Fixing cat path..."
    ${gnused}/bin/sed -i"" 's|\(/bin/cat\)|${coreutils}\1|g' src/wl-paste.c
  '';

  nativeBuildInputs = [
    meson ninja pkgconfig git
  ];
  buildInputs = [
    wayland wayland-protocols
  ];

  enableParallelBuilding = true;

  #cmakeFlags = "-DVERSION=${version} -DLD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver-32/lib";

  meta = with stdenv.lib; {
    description = "Hacky clipboard manager for Wayland";
    homepage    = https://github.com/bugaevc/wl-clipboard;
    license     = licenses.gpl3;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ primeos ]; # Trying to keep it up-to-date.
  };
}
