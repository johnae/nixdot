{ stdenv, fetchgit, wget, perl, cacert }:

stdenv.mkDerivation rec {
  version = "0.9.6";
  name = "spook-${version}";
  SPOOK_VERSION = version;

  src = fetchgit {
    url = https://github.com/johnae/spook.git;
    rev = "0.9.6";
    sha256 = "12k7n0g1mbaaf0wnbhdvmyn18kwidd24faz50w0b6akxlds85ml1";
    fetchSubmodules = true;
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    make install PREFIX=$out
    runHook postInstall
  '';

  buildInputs = [ wget perl cacert ];

  meta = {
    description = "Lightweight evented utility for monitoring file changes and more";
    homepage = https://github.com/johnae/spook;
    license = "MIT";
  };

}
