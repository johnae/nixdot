{ stdenv, fetchFromGitHub
, meson, ninja
, pkgconfig, scdoc
, wayland, wayland-protocols, libxkbcommon
, pcre, json_c, dbus, pango, cairo, libinput
, libcap, pam, gdk_pixbuf, libevdev, wlroots
, buildDocs ? true
}:

stdenv.mkDerivation rec {
  name = "sway-${version}";
  version = "23f075e71d985754effde5372f4242ddb09cbbc0";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "sway";
    rev = version;
    sha256 = "0la66c5xk5110rhwa9c09br4spy2zcjh8r1zk26fklrj5w3f4v7y";
  };

  nativeBuildInputs = [
    pkgconfig meson ninja
  ] ++ stdenv.lib.optional buildDocs scdoc;

  buildInputs = [
    wayland wayland-protocols libxkbcommon pcre json_c dbus
    pango cairo libinput libcap pam gdk_pixbuf
    wlroots libevdev
  ];

  postPatch = ''
    sed -iE "s/version: '1.0',/version: '${version}',/" meson.build
  '';

   mesonFlags = [
   "-Dxwayland=enabled" "-Dgdk-pixbuf=enabled" "-Dtray=enabled"
   ] ++ stdenv.lib.optional buildDocs "-Dman-pages=enabled";

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "i3-compatible window manager for Wayland";
    homepage    = http://swaywm.org;
    license     = licenses.mit;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ {
      email = "john@insane.se";
      github = "johnae";
      name = "John Axel Eriksson";
    } ];
  };
}
