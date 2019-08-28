{ stdenv, rustPlatform, fetchFromGitHub, pkgconfig, dbus, libpulseaudio, alsaLib, openssl }:

let
  metadata = builtins.fromJSON (builtins.readFile ./metadata.json);
in
rustPlatform.buildRustPackage rec {
  pname = metadata.repo;
  version = metadata.rev;

  src = fetchFromGitHub metadata;
  cargoSha256 = "15bs0yk6jcspvwfcpzaqh3jyfk0m4i4c3r1fxcw33ys4waidx3c4";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [
     libpulseaudio
     openssl
     pkgconfig
     alsaLib
     dbus
  ];

  doCheck = false;
  cargoBuildFlags = [ "--features pulseaudio_backend,dbus_mpris" ];

  meta = with stdenv.lib; {
    description = "Simple spotify device daemon";
    homepage = https://github.com/spotifyd/spotifyd;
    license = licenses.gpl3;
    maintainers = [{
      email = "john@insane.se";
      github = "johnae";
      name = "John Axel Eriksson";
    }];
  };
}
