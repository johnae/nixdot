{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, git
, asciidoc, libxslt, docbook_xsl, scdoc
, wayland, wayland-protocols
, buildDocs ? true
}:

stdenv.mkDerivation rec {
  name = "swayidle-${version}";
  version = "d5acddb7b03efa77383879f2ae419a28933bb07c";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "swayidle";
    rev = version;
    sha256 = "08lwsqxy2lgvn50lianxl02v1041py7bn3s09m2xvvr4by4mj4zp";
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