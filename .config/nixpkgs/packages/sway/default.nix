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
  version = "c36665bc17d1950672330788040e07953d4fb638";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "sway";
    rev = version;
    sha256 = "0pqhirk419dizn592cip2wjyfaa6nrx3169slzr3zh2jisqqnkpc";
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
