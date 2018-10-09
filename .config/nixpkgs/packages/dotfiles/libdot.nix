{stdenv, lib, coreutils, attr, ...}:

with lib;

let

  install = xs: fun: concatStringsSep "\n" (concatMap (x: (mapAttrsToList fun x.paths)) xs);

  toConfig = xs: fun: concatStringsSep "\n" (concatMap (x: (mapAttrsToList fun x)) xs);

  mkdir = {path, mode ? "0755"}: ''
        ${coreutils}/bin/echo "mkdir $PWD/${path} with mode ${mode}"
        ${coreutils}/bin/mkdir -p ${path}
        ${coreutils}/bin/echo ${coreutils}/bin/chmod ${mode} ${path} >> set-permissions.sh
  '';

  copy = {path, to, mode ? "0644"}: ''
        ${coreutils}/bin/echo "copy ${path} to $PWD/${to} with mode ${mode}"
        ${coreutils}/bin/cat ${path} > ${to}
        dir=$(${coreutils}/bin/dirname ${to})
        name=$(${coreutils}/bin/basename ${to})
        ${coreutils}/bin/echo ${coreutils}/bin/chmod ${mode} ${to} >> set-permissions.sh
  '';

in

{
  install = install;
  toConfig = toConfig;
  mkdir = mkdir;
  copy = copy;
}