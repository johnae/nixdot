{ stdenv, fetchFromGitHub, coreutils, gnused, meson, ninja, pkgconfig, wayland, wayland-protocols, git, systemd}:

stdenv.mkDerivation rec {
  name = "wl-clipboard-${version}";
  version = "bd6454d37973b8950977b880458bd98d43578256";

  src = fetchFromGitHub {
    owner = "bugaevc";
    repo = "wl-clipboard";
    rev = version;
    sha256 = "1nmz4v2pkwnqgcm0v6pg7nd3jmsqbrdjy5g2x85w22wrb27zxnfn";
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
