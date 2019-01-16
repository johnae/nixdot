{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, git
, asciidoc, libxslt, docbook_xsl, scdoc
, wayland, wayland-protocols
, buildDocs ? true
}:

stdenv.mkDerivation rec {
  name = "swayidle-${version}";
  version = "05d7ffe755e87fb08bf4c887299146e2bd1af787";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "swayidle";
    rev = version;
    sha256 = "0a6f9b6q9qldmkgzszyy90l3j3ilkfpm56238qiy6cg9xgs9khfn";
  };

  nativeBuildInputs = [
    meson ninja pkgconfig git
  ] ++ stdenv.lib.optional buildDocs [ scdoc asciidoc libxslt docbook_xsl ];
  buildInputs = [
    wayland wayland-protocols
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