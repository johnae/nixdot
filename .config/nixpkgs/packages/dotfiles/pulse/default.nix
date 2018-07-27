{stdenv, writeText, ...}:

let
  config = writeText "user-pulse-config" ''
    .include /etc/pulse/default.pa
    # automatically switch to newly-connected devices
    load-module module-switch-on-connect
  '';
in

  {
    paths = { ".config/pulse/default.pa" = config; };
  }