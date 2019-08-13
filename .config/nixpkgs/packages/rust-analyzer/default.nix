{ stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform
}:

with rustPlatform;

let

  metadata = builtins.fromJSON(builtins.readFile ./metadata.json);

in

  buildRustPackage rec {
    pname = metadata.repo;
    version = metadata.rev;
    doCheck = false;

    src = fetchFromGitHub {
      owner = metadata.owner;
      repo = pname;
      rev = "${version}";
      sha256 = metadata.sha256;
    };

    cargoSha256 = "0lxyfnwijga5hrjwr6n4zs86nw503w01fygjk2pj6x7jmzs07klx";

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
