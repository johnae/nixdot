{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig
, asciidoc, libxslt, docbook_xsl, scdoc
, wayland, wayland-protocols, xwayland, libxkbcommon
, pcre, json_c, dbus_libs, pango, cairo, libinput
, libcap, pam, gdk_pixbuf, libpthreadstubs, libevdev
, libXdmcp, wlroots, git, systemd, wrapGAppsHook
, buildDocs ? true
}:

stdenv.mkDerivation rec {
  name = "sway-${version}";
  version = "70637b40fe98bda420e279e2e059fc93a9f538d6";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "sway";
    rev = version;
    sha256 = "0mlkx3w72xhlh0df569rwbjv56h3yhykibbxcrh5my13chx9lrvg";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig git wrapGAppsHook
  ] ++ stdenv.lib.optional buildDocs [ scdoc asciidoc libxslt docbook_xsl ];
  buildInputs = [
    wayland wayland-protocols xwayland libxkbcommon pcre json_c dbus_libs
    pango cairo libinput libcap pam gdk_pixbuf libpthreadstubs
    libXdmcp wlroots systemd libevdev
  ];

  mesonFlags = [
    "-Dsway-version=${version}"
    "-Dauto_features=enabled"
    "-Denable-tray=true"
  ];

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
