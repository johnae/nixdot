{ stdenv, fetchgit, gnumake, gcc, wget, perl, cacert }:

stdenv.mkDerivation rec {
  version = "0.9.6-pre";
  name = "spook-${version}";
  SPOOK_VERSION = version;

  src = fetchgit {
    url = https://github.com/johnae/spook.git;
    rev = "10c817ecef6cc57ad36f66930eed167da512fed7";
    sha256 = "05ix72zix48snn6dc76mvxycb1q96z0bbc1k8hw1kbp4r0jc77f4";
    fetchSubmodules = true;
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    make install PREFIX=$out
    runHook postInstall
  '';

  buildInputs = [ gnumake gcc wget perl cacert ];

  meta = {
    description = "Lightweight evented utility for monitoring file changes and more";
    homepage = https://github.com/johnae/spook;
    license = "MIT";
  };

}
