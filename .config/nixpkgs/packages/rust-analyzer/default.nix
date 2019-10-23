{ stdenv,
  lib,
  fetchFromGitHub,
  pkgs
}:

let

  metadata = builtins.fromJSON(builtins.readFile ./metadata.json);
  nightlyRustPlatform =
    let
      nightly = pkgs.rustChannelOf {
        date = "2019-10-20";
        channel = "nightly";
      };
    in
    pkgs.makeRustPlatform {
      rustc = nightly.rust;
      cargo = nightly.rust;
    };

in

  with nightlyRustPlatform; buildRustPackage rec {
    pname = metadata.repo;
    version = metadata.rev;
    doCheck = false;

    src = fetchFromGitHub metadata;

    cargoSha256 = "1rg0jv0pr57mryl1a4h698qpzplj5s3lhg66g78c62lsrjzf609g";

    outputs = [ "out" ];

    meta = with stdenv.lib; {
      description = "Rust Analyzer";
      homepage = https://github.com/rust-analyzer/rust-analyzer;
      license = licenses.mit;
      maintainers = [{
        email = "john@insane.se";
        github = "johnae";
        name = "John Axel Eriksson";
      }];
    };
  }
