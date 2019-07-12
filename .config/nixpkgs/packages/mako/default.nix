{ stdenv, fetchFromGitHub, meson, ninja, pkgconfig, wayland, scdoc,
  wayland-protocols, gdk_pixbuf, dbus_libs, pango, cairo, git, systemd
}:

let

  metadata = builtins.fromJSON (builtins.readFile ./metadata.json);

in

  stdenv.mkDerivation rec {
    name = "${metadata.repo}-${version}";
    version = metadata.rev;

    src = fetchFromGitHub metadata;

    nativeBuildInputs = [
      meson ninja pkgconfig git scdoc
    ];
    buildInputs = [
      wayland wayland-protocols dbus_libs
      pango cairo systemd gdk_pixbuf
    ];

    meta = with stdenv.lib; {
      description = "notification daemon for Wayland";
      homepage    = https://mako-project.org/;
      license     = licenses.mit;
      platforms   = platforms.linux;
    };
  }