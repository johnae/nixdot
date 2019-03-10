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
  version = "a6711740bcd311e1ee551c83a5dfc46d9344d17e";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "sway";
    rev = version;
    sha256 = "0xrgbn6byw9wip4sfazk0qv9cy0m8jszhcgffh3kg9r5g5xf03zf";
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
