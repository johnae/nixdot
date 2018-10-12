{stdenv, lib, coreutils, attr, ...}:

with lib;

let

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
  mkdir = mkdir;
  copy = copy;
}