{ stdenv, fetchgit, wget, perl, cacert }:

stdenv.mkDerivation rec {
  version = "0.9.7-pre";
  name = "spook-${version}";
  SPOOK_VERSION = version;

  src = fetchgit {
    url = https://github.com/johnae/spook.git;
    rev = "fa85bbcf58f038a9190762b0dbb2ba7edbed2ad4";
    sha256 = "0ksa5scw9ilbhaxx6p95hgfwqbv55328yim8k40m8pfakkpmk06x";
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
