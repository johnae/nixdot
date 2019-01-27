{ stdenv, fetchFromGitHub, coreutils, gnused, meson, ninja, pkgconfig, wayland, wayland-protocols, git, systemd}:

stdenv.mkDerivation rec {
  name = "wl-clipboard-${version}";
  version = "46f21d2ef1547c1c6becd12ec863cdb8b7e51691";

  src = fetchFromGitHub {
    owner = "bugaevc";
    repo = "wl-clipboard";
    rev = version;
    sha256 = "0vqwfr0q8xr0pp05hmffjrz4kjbc1a4cdd4v97lbkhh21wbaa9wb";
  };

  preConfigure = ''
    echo "Fixing cat path..."
    ${gnused}/bin/sed -i"" 's|\(/bin/cat\)|${coreutils}\1|g' src/wl-paste.c
  '';

  nativeBuildInputs = [
    meson ninja pkgconfig git
  ];
  buildInputs = [
    wayland wayland-protocols
  ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Hacky clipboard manager for Wayland";
    homepage    = https://github.com/bugaevc/wl-clipboard;
    license     = licenses.gpl3;
    platforms   = platforms.linux;
    maintainers = with maintainers; [ primeos ]; # Trying to keep it up-to-date.
  };
}
