
{ stdenv, rustPlatform, fetchFromGitHub, pkgconfig, openssl }:

let
  metadata = builtins.fromJSON (builtins.readFile ./metadata.json);
in
rustPlatform.buildRustPackage rec {
  pname = metadata.repo;
  version = metadata.rev;

  src = fetchFromGitHub metadata;
  cargoSha256 = "029g80mcqvmckszpbzm4hxs5w63n41ah4rc1b93i9c1nzvncd811";

  nativeBuildInputs = [ pkgconfig ];

  buildInputs = [
     openssl
     pkgconfig
  ];

  doCheck = false;
  #cargoBuildFlags = [ "--features pulseaudio_backend,dbus_mpris" ];
  #cargoBuildFlags = [ "--features pulseaudio_backend" ];

  meta = with stdenv.lib; {
    description = "Spotify for the terminal";
    homepage = https://github.com/Rigellute/spotify-tui;
    license = licenses.mit;
    maintainers = [{
      email = "john@insane.se";
      github = "johnae";
      name = "John Axel Eriksson";
    }];
  };
}
