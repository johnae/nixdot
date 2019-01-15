{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, udev, systemd
, wayland, libGL, wayland-protocols, xwayland, libinput, libxkbcommon, pixman
, xcbutilwm, libX11, libcap, xcbutilimage, xcbutilerrors, libdrm, mesa_noglu
}:

stdenv.mkDerivation rec {
  name = "wlroots";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "wlroots";
    rev = "dc9c91b0a4a973f100ead0c2b1dad9f0699a8a69";
    sha256 = "194f9cs891is30mmk50j4zkr84i0l66srxkiic5m6vxympkwffhk";
  };

  # $out for the library and $bin for rootston
  outputs = [ "out" "bin" ];

  nativeBuildInputs = [ meson ninja pkgconfig ];

  mesonFlags = [ "-Dauto_features=enabled" ];

  buildInputs = [
    wayland libGL wayland-protocols xwayland libinput libxkbcommon pixman
    xcbutilwm libX11 libcap xcbutilimage xcbutilerrors mesa_noglu libdrm
    libcap systemd
  ];

  # Install rootston (the reference compositor) to $bin
  postInstall = ''
    mkdir -p $bin/bin
    cp rootston/rootston $bin/bin/
    mkdir $bin/lib
    cp libwlroots* $bin/lib/
    patchelf --set-rpath "$bin/lib:${stdenv.lib.makeLibraryPath buildInputs}" \
        $bin/bin/rootston
    mkdir $bin/etc
    cp ../rootston/rootston.ini.example $bin/etc/rootston.ini
  '';

  meta = with stdenv.lib; {
    description = "A modular Wayland compositor library";
    inherit (src.meta) homepage;
    license     = licenses.mit;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ {
      email = "john@insane.se";
      github = "johnae";
      name = "John Axel Eriksson";
    } ];
  };
}
