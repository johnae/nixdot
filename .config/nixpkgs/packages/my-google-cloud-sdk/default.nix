{ stdenv, lib, fetchurl, makeWrapper, pkgs, withExtras ? true }:

let
  python = pkgs.python;
  coreutils = pkgs.coreutils;
  pp = pkgs.python2Packages;
  pythonInputs = [ pp.cffi pp.cryptography pp.pyopenssl pp.crcmod ];
  pythonPath = lib.makeSearchPath python.sitePackages pythonInputs;
  gcloudVersion = "243.0.0";

  # see: https://console.cloud.google.com/storage/browser/cloud-sdk-release?authuser=0
  componentBaseUrl = "https://storage.googleapis.com/cloud-sdk-release/for_packagers/linux";
  appengine-go-sdk-component = {
    url = "${componentBaseUrl}/google-cloud-sdk-app-engine-go_${gcloudVersion}.orig_amd64.tar.gz";
    sha256 = "17g50phpq6m4wnz5jf9jxavmpaqgi5vcdvpbsji7ain4190pkln3";
  };

  appengine-python-sdk-component = {
    url = "${componentBaseUrl}/google-cloud-sdk-app-engine-python_${gcloudVersion}.orig.tar.gz";
    sha256 = "0smgk97srkh8m2ag24msxjxrjjfxz47gcc2r6ccxzg11vj39b41p";
  };

  datastore-emulator-component = {
    url = "${componentBaseUrl}/google-cloud-sdk-datastore-emulator_${gcloudVersion}.orig.tar.gz";
    sha256 = "0bfg1rd6f4p3kxa4a9jd07krclfklfgg496iy7962pqgjk34gfyr";
  };

  pub-sub-emulator-component = {
    url = "${componentBaseUrl}/google-cloud-sdk-pubsub-emulator_${gcloudVersion}.orig.tar.gz";
    sha256 = "0giyab4kab50w7yzyqgg6d6f7426g4igg03kn22hmrd009dxz53f";
  };

  baseUrl = "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads";
  sources = name: system: {
    x86_64-linux = {
      url = "${baseUrl}/${name}-linux-x86_64.tar.gz";
      sha256 = "0drypkgias3hklccw2l5h6dj17r8fz0l9yprvglpj0ay1qs4q3fh";
    };
    x86_64-darwin = {
      url = "${baseUrl}/${name}-darwin-x86_64.tar.gz";
      sha256 = "12h63v2klvbjm5aaqpz5n8nywp3srip84gyb56dzdpmcg61qjpcr";
    };
  }.${system};

in stdenv.mkDerivation rec {
  name = "google-cloud-sdk-${version}";
  version = gcloudVersion;

  src = fetchurl (sources name stdenv.system);

  installExtras = if withExtras then
    let
       appengine-go-sdk = fetchurl appengine-go-sdk-component;
       appengine-python-sdk = fetchurl appengine-python-sdk-component;
       pub-sub-emulator = fetchurl pub-sub-emulator-component;
       datastore-emulator = fetchurl datastore-emulator-component;
    in
       ''
         echo "Installing app engine go sdk..."
         tar -zxf "${appengine-go-sdk}" -C "$out"

         echo "Installing app engine python sdk..."
         tar -zxf "${appengine-python-sdk}" -C "$out"

         echo "Installing pub sub emulator..."
         tar -zxf "${pub-sub-emulator}" -C "$out"

         echo "Installing datastore emulator..."
         tar -zxf "${datastore-emulator}" -C "$out"
       ''
  else
    ''
      echo "Skipping installing extras..."
    '';


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

    ${installExtras}

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
    priority = 6;
  };
}
