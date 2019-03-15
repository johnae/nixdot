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
  version = "acdb4ed7a32a7cefd4ac37190ba65d33d752bee0";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "sway";
    rev = version;
    sha256 = "092dmsv9dd85p6sbqk7z7w357yc36hpa2val3z61z0ibjizygljg";
  };

  nativeBuildInputs = [
    pkgconfig meson ninja
  ] ++ stdenv.lib.optional buildDocs scdoc;

  buildInputs = [
    wayland wayland-protocols libxkbcommon pcre json_c dbus
    pango cairo libinput libcap pam gdk_pixbuf
    wlroots libevdev scdoc
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
