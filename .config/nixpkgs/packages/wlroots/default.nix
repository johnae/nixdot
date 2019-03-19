{ stdenv, fetchFromGitHub, fetchpatch, meson, ninja, pkgconfig
, wayland, libGL, wayland-protocols, libinput, libxkbcommon, pixman
, xcbutilwm, libX11, libcap, xcbutilimage, xcbutilerrors, mesa_noglu
, libpng, ffmpeg_4
}:

let

  metadata = builtins.fromJSON (builtins.readFile ./metadata.json);

in

  stdenv.mkDerivation rec {
    name = metadata.repo;
    version = metadata.rev;

    src = fetchFromGitHub metadata;

    # $out for the library and $bin for rootston
    outputs = [ "out" "bin" "examples" ];

    nativeBuildInputs = [ meson ninja pkgconfig ];

     mesonFlags = [
      "-Dlibcap=enabled" "-Dlogind=enabled" "-Dxwayland=enabled" "-Dx11-backend=enabled"
      "-Dxcb-icccm=enabled" "-Dxcb-errors=enabled"
    ];

    buildInputs = [
      wayland libGL wayland-protocols libinput libxkbcommon pixman
      xcbutilwm libX11 libcap xcbutilimage xcbutilerrors mesa_noglu
      libpng ffmpeg_4
    ];

    #postPatch = ''
    #  sed -iE "s/version: '[0-9]\.[0-9]\.[0-9]'/version: '${version}.0'/" meson.build
    #'';

    postInstall = ''
      for output in "$bin" "$examples"; do
        mkdir -p $output/lib
        cp -P libwlroots* $output/lib/
      done
    '';

    postFixup = ''
      # Install rootston (the reference compositor) to $bin and $examples (this
      # has to be done after the fixup phase to prevent broken binaries):
      for output in "$bin" "$examples"; do
        mkdir -p $output/bin
        cp rootston/rootston $output/bin/
        patchelf \
          --set-rpath "$(patchelf --print-rpath $output/bin/rootston | sed s,$out,$output,g)" \
          $output/bin/rootston
        mkdir $output/etc
        cp ../rootston/rootston.ini.example $output/etc/rootston.ini
      done
      # Install ALL example programs to $examples:
      # screencopy dmabuf-capture input-inhibitor layer-shell idle-inhibit idle
      # screenshot output-layout multi-pointer rotation tablet touch pointer
      # simple
      mkdir -p $examples/bin
      cd ./examples
      for binary in $(find . -executable -type f -printf '%P\n' | grep -vE '\.so'); do
        cp "$binary" "$examples/bin/wlroots-$binary"
        patchelf \
          --set-rpath "$(patchelf --print-rpath $output/bin/rootston | sed s,$out,$examples,g)" \
          "$examples/bin/wlroots-$binary"
      done
    '';

    meta = with stdenv.lib; {
      description = "A modular Wayland compositor library";
      inherit (src.meta) homepage;
      license     = licenses.mit;
      platforms   = platforms.linux;
      maintainers = with maintainers; [ {
        email = "john@insane.se";
        github = "johnae";
        name = "John Axel Eriksson";
      } ];
    };
  }
