{ stdenv, fetchFromGitHub
, meson, ninja, pkgconfig
, wayland, wayland-protocols, sway, wlroots
, libpulseaudio, libinput, libnl, gtkmm3
, fmt, jsoncpp, libdbusmenu-gtk3
, glib
, git
}:

let

  metadata = builtins.fromJSON (builtins.readFile ./metadata.json);

in

  stdenv.mkDerivation rec {
    name = "${metadata.repo}-${version}";
    version = metadata.rev;

    src = fetchFromGitHub metadata;

    nativeBuildInputs = [ meson ninja pkgconfig ];
    buildInputs = [
      wayland wayland-protocols sway wlroots
      libpulseaudio libinput libnl gtkmm3
      git fmt jsoncpp libdbusmenu-gtk3
      glib
    ];
    mesonFlags = [
      "-Dauto_features=enabled"
      "-Dout=${placeholder "out"}"
    ];

    enableParallelBuilding = true;

    meta = with stdenv.lib; {
      description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
      homepage    = https://github.com/Alexays/Waybar;
      license     = licenses.mit;
      platforms   = platforms.linux;
      maintainers = with maintainers; [ {
        email = "john@insane.se";
        github = "johnae";
        name = "John Axel Eriksson";
      } ];
    };
  }