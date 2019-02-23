{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, git
, asciidoc, libxslt, docbook_xsl, scdoc
, wayland, wayland-protocols, systemd
, buildDocs ? true
}:

stdenv.mkDerivation rec {
  name = "swayidle-${version}";
  version = "3e392e31c0684854a9a145cda1bd9a44c99ef24d";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "swayidle";
    rev = version;
    sha256 = "04agcbhc473jkk7npb40i94ny8naykxzpjcw2lvl05kxv65y5d9v";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig git
  ] ++ stdenv.lib.optional buildDocs [ scdoc asciidoc libxslt docbook_xsl ];
  buildInputs = [
    wayland wayland-protocols systemd
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