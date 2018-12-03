{ stdenv, fetchFromGitHub, meson048, ninja, pkgconfig
, asciidoc, libxslt, docbook_xsl, scdoc
, wayland, wayland-protocols, xwayland, libxkbcommon
, pcre, json_c, dbus_libs, pango, cairo, libinput
, libcap, pam, gdk_pixbuf, libpthreadstubs
, libXdmcp, wlroots, git, systemd, wrapGAppsHook
, buildDocs ? true
}:

stdenv.mkDerivation rec {
  name = "sway-${version}";
  version = "bca21ee0cf504f7878a5a2a80cc30cb09e5d5509";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "sway";
    rev = version;
    sha256 = "14zsl2m8mi21lj2k1y49q29xjf82nrvgff3bnspzcgaz8ad2z4sy";
  };

  nativeBuildInputs = [
    meson048 ninja pkgconfig git wrapGAppsHook
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
