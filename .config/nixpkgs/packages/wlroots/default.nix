{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, udev, systemd
, wayland, libGL, wayland-protocols, xwayland, libinput, libxkbcommon, pixman
, xcbutilwm, libX11, libcap, xcbutilimage, xcbutilerrors, libdrm, mesa_noglu
}:

stdenv.mkDerivation rec {
  name = "wlroots";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "wlroots";
    rev = "9921f9b28da1e34e9cbcd32a78ea72f62cd9a2d2";
    sha256 = "14l5v3xzilbvv7hff85xblv3p3bn4ag9wxmar41s4hyavafblcv6";
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
    maintainers = with maintainers; [ primeos ];
  };
}
