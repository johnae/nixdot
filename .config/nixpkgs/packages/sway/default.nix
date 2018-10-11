{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, asciidoc, libxslt, docbook_xsl, scdoc
, wayland, wayland-protocols, xwayland, libxkbcommon, pcre, json_c, dbus_libs
, pango, cairo, libinput, libcap, pam, gdk_pixbuf, libpthreadstubs
, libXdmcp, wlroots, git, systemd, wrapGAppsHook
, buildDocs ? true
}:

stdenv.mkDerivation rec {
  name = "sway-${version}";
  version = "8dadfd42dff1531f793ad2f2c237a05c05f6d180";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "sway";
    rev = version;
    sha256 = "0k4q3niz6r4dg1nr962gs7fnhs75z71iv5nhpgx0al6nk47kkd1a";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig git wrapGAppsHook
  ] ++ stdenv.lib.optional buildDocs [ asciidoc libxslt docbook_xsl ];
  buildInputs = [
    wayland wayland-protocols xwayland libxkbcommon pcre json_c dbus_libs
    pango cairo libinput libcap pam gdk_pixbuf libpthreadstubs
    libXdmcp wlroots systemd
  ];

  mesonFlags = [
    "-Dsway-version=${version}"
    "-Dauto_features=enabled"
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "i3-compatible window manager for Wayland";
    homepage    = http://swaywm.org;
    license     = licenses.mit;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ primeos ]; # Trying to keep it up-to-date.
  };
}
