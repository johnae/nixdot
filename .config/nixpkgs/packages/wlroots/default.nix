{ stdenv, fetchFromGitHub, meson048, ninja, pkgconfig, udev, systemd
, wayland, libGL, wayland-protocols, xwayland, libinput, libxkbcommon, pixman
, xcbutilwm, libX11, libcap, xcbutilimage, xcbutilerrors, libdrm, mesa_noglu
}:

let pname = "wlroots";
    version = "2018-10-16";

in stdenv.mkDerivation rec {
  name = "${pname}"; #-${version}";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "wlroots";
    rev = "f34b7f88006c3be5fc5283d86f206ac75cf20093";
    sha256 = "0mh45944zcy653na19m8s26dxirjizs159wdyac9i2dxvf0pyz83";
  };

  patches = [
    ./0001-Add-fix.patch
  ];

  # $out for the library and $bin for rootston
  outputs = [ "out" "bin" ];

  nativeBuildInputs = [ meson048 ninja pkgconfig ];

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
