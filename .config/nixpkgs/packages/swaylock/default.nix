{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, git
, asciidoc, libxslt, docbook_xsl, scdoc
, wayland, wayland-protocols, libxkbcommon
, cairo, pam, gdk_pixbuf
, buildDocs ? true
}:

stdenv.mkDerivation rec {
  name = "swaylock-${version}";
  version = "368f53e4f15ecac51c01e6d1a45c43d31d4bca20";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "swaylock";
    rev = version;
    sha256 = "00x5yw8cp21dkjz6cv279jc6k970ixrbz39c7cm55liydbslqykh";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig git
  ] ++ stdenv.lib.optional buildDocs [ scdoc asciidoc libxslt docbook_xsl ];
  buildInputs = [
    wayland wayland-protocols cairo pam gdk_pixbuf libxkbcommon
  ];

  mesonFlags = [ "-Dauto_features=enabled" ];

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