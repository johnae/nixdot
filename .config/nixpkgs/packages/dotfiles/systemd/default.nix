{stdenv, libdot, lib, writeText, settings, pkgs, ...}:

with lib;
with libdot;

let

  environment-import = {
    Unit = {
      Description = "Environment Import Target";
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/true";
    };
  };

  services = (mapAttrs (name: value:
    let
      Requires = (value.Unit.Requires or []) ++ [ "environment-import.service" ];
      After = (value.Unit.After or []) ++ [ "environment-import.service" ];
    in
      recursiveUpdate value {
        Unit = {
          inherit Requires After;
        };
      }
  ) settings.services) // { inherit environment-import; };

  toSystemdIni = generators.toINI {
      mkKeyValue = key: value:
        let
          value' =
            if isBool value then (if value then "true" else "false")
            else toString value;
        in
          "${key}=${value'}";
    };

  create-service = name: def:
  let
    svc = writeText "${name}.service" (toSystemdIni def);
  in
    ''
       ${libdot.copy { path = svc; to = ".config/systemd/user/${name}.service"; }}
    '';

in
  {
    __toString = self: ''
      echo "Ensuring .config/systemd/user directory..."
      ${libdot.mkdir { path = ".config/systemd/user"; }}
      ${concatStringsSep "\n" (mapAttrsToList create-service services)}
    '';
  }
