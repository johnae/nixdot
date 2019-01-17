{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, git
, asciidoc, libxslt, docbook_xsl, scdoc
, wayland, wayland-protocols, libxkbcommon
, pango, cairo, pam, gdk_pixbuf
, buildDocs ? true
}:

stdenv.mkDerivation rec {
  name = "swaylock-${version}";
  version = "5303a5f3004e9e8e9f43b805086b1aee9376ba49";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "swaylock";
    rev = version;
    sha256 = "0m3cig5hjjlqcw7hdawnk3yl9zcn9n3yf3ak0vd9n5xkgvwg3n9q";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig git
  ] ++ stdenv.lib.optional buildDocs [ scdoc asciidoc libxslt docbook_xsl ];
  buildInputs = [
    wayland wayland-protocols pango cairo pam gdk_pixbuf libxkbcommon
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Sway's idle management daemon.";
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