{stdenv, lib, libdot, writeText, settings, ...}:

with settings.ssh;

let

  toHost = h: lib.concatStringsSep "\n" (lib.mapAttrsToList
         (name: value: ''${"  "}${name} ${value}'') h);

  toHosts = hs: lib.concatStringsSep "\n" (lib.mapAttrsToList
          (name: value: ''
          Host ${name}
          ${toHost value}
          '') hs);

  config = writeText "ssh-config" (toHosts hosts);

in

  {
    __toString = self: ''
      ${libdot.mkdir { path = ".ssh"; mode = "0700"; }}
      ${libdot.copy { path = config; to = ".ssh/config"; mode = "0600"; }}
    '';
  }