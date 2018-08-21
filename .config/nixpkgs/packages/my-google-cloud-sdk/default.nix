{ stdenv, lib, fetchurl, makeWrapper, pkgs, ... }:

let
  python = pkgs.python;
  coreutils = pkgs.coreutils;
  pp = pkgs.python2Packages;
  pythonInputs = [ pp.cffi pp.cryptography pp.pyopenssl pp.crcmod ];
  pythonPath = lib.makeSearchPath python.sitePackages pythonInputs;
  gcloudVersion = "212.0.0";

  componentBaseUrl = "https://storage.googleapis.com/cloud-sdk-release/for_packagers/linux";
  appengine-go-sdk-component = {
    url = "${componentBaseUrl}/google-cloud-sdk-app-engine-go_${gcloudVersion}.orig_amd64.tar.gz";
    sha256 = "1vz5qxgmmpcz8r8jr76gkqx5jdcrj9zl6fw79hy2l1h1qcifa9z0";
  };

  pub-sub-emulator-component = {
    url = "${componentBaseUrl}/google-cloud-sdk-pubsub-emulator_${gcloudVersion}.orig.tar.gz";
    sha256 = "0kgdcq9fjns08m6sz8yg2da9gjrjxkll171hpsdz74r2yvr8lwvc";
  };

  baseUrl = "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads";
  sources = name: system: {
    x86_64-linux = {
      url = "${baseUrl}/${name}-linux-x86_64.tar.gz";
      sha256 = "10f6v7r72l6cxvhj1rq8g0q0yzcq3lav6f62n1il603j2q9r2lcg";
    };
  }.${system};

in stdenv.mkDerivation rec {
  name = "google-cloud-sdk-${version}";
  version = gcloudVersion;

  src = fetchurl (sources name stdenv.system);
  appengine-go-sdk = fetchurl appengine-go-sdk-component;
  pub-sub-emulator = fetchurl pub-sub-emulator-component;

  buildInputs = [ python makeWrapper ];

  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
    mkdir -p "$out"
    tar -xzf "$src" -C "$out" google-cloud-sdk

    mkdir $out/google-cloud-sdk/lib/surface/alpha
    cp ${./alpha__init__.py} $out/google-cloud-sdk/lib/surface/alpha/__init__.py

    mkdir $out/google-cloud-sdk/lib/surface/beta
    cp ${./beta__init__.py} $out/google-cloud-sdk/lib/surface/beta/__init__.py

    # create wrappers with correct env
    for program in gcloud bq gsutil git-credential-gcloud.sh docker-credential-gcloud; do
        programPath="$out/google-cloud-sdk/bin/$program"
        binaryPath="$out/bin/$program"
        wrapProgram "$programPath" \
            --set CLOUDSDK_PYTHON "${python}/bin/python" \
            --prefix PYTHONPATH : "${pythonPath}" \
            --prefix PATH : "${coreutils}/bin"

        mkdir -p $out/bin
        ln -s $programPath $binaryPath
    done

    echo "Installing app engine go sdk..."
    tar -zxf "${appengine-go-sdk}" -C "$out"

    echo "Installing pub sub emulator..."
    tar -zxf "${pub-sub-emulator}" -C "$out"

    # disable component updater and update check
    substituteInPlace $out/google-cloud-sdk/lib/googlecloudsdk/core/config.json \
      --replace "\"disable_updater\": false" "\"disable_updater\": true"
    echo "
    [component_manager]
    disable_update_check = true" >> $out/google-cloud-sdk/properties

    # setup bash completion
    mkdir -p "$out/etc/bash_completion.d/"
    mv "$out/google-cloud-sdk/completion.bash.inc" "$out/etc/bash_completion.d/gcloud.inc"

    # This directory contains compiled mac binaries. We used crcmod from
    # nixpkgs instead.
    rm -r $out/google-cloud-sdk/platform/gsutil/third_party/crcmod
  '';

  meta = with stdenv.lib; {
    description = "Tools for the google cloud platform";
    longDescription = "The Google Cloud SDK. This package has the programs: gcloud, gsutil, and bq";
    # This package contains vendored dependencies. All have free licenses.
    license = licenses.free;
    homepage = "https://cloud.google.com/sdk/";
    maintainers = with maintainers; [ stephenmw zimbatm ];
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
  };
}
