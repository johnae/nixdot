{ stdenv, fetchFromGitHub, ghc }:

stdenv.mkDerivation rec {
  version = "1.0.0";
  name = "fire-${version}";

  src = fetchFromGitHub {
    owner = "johnae";
    repo = "fire";
    rev = "ec28249213bc0539f43693d06985072061ae6b09";
    sha256 = "1mszff839ksjivj1w3shih1s6mvmh1pi187w30c13fvipaab62d4";
  };

  buildPhase = ''
    ghc -O2 fire.hs
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp fire $out/bin/
    runHook postInstall
  '';

  buildInputs = [ ghc ];

  meta = {
    description = "Simple launcher (creates new process group for exec'd process)";
    homepage = https://github.com/johnae/fire;
    license = "MIT";
  };
}
