{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, asciidoc, libxslt, docbook_xsl, scdoc
, wayland, wayland-protocols, xwayland, libxkbcommon, pcre, json_c, dbus_libs
, pango, cairo, libinput, libcap, pam, gdk_pixbuf, libpthreadstubs
, libXdmcp, wlroots, git, systemd, wrapGAppsHook
, buildDocs ? true
}:

stdenv.mkDerivation rec {
  name = "sway-${version}";
  version = "56c388b51076c3d96363e6afb62d0138cd3dce36";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "sway";
    rev = version;
    sha256 = "0ba49zkgd2q04zvfg3f00l7nhp9k1yzf4yvhslzbyzlqddjwcdvy";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig git wrapGAppsHook
  ] ++ stdenv.lib.optional buildDocs [ asciidoc libxslt docbook_xsl ];
  buildInputs = [
    wayland wayland-protocols xwayland libxkbcommon pcre json_c dbus_libs
    pango cairo libinput libcap pam gdk_pixbuf libpthreadstubs
    libXdmcp wlroots systemd
  ];

  CFLAGS = "-std=gnu99";

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
