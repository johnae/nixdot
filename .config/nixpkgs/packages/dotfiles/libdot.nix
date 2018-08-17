{stdenv, lib, coreutils, attr, ...}:

let

  install = xs: fun: lib.concatStringsSep "\n" (lib.concatMap (x: (lib.mapAttrsToList fun x.paths)) xs);

  mkdir = {path, mode ? "0755"}: ''
        ${coreutils}/bin/echo "mkdir $PWD/${path} with mode ${mode}"
        ${coreutils}/bin/mkdir -p ${path}
        ${coreutils}/bin/echo ${path}:${mode} >> .permissions
  '';

  copy = {path, to, mode ? "0644"}: ''
        ${coreutils}/bin/echo "copy ${path} to $PWD/${to} with mode ${mode}"
        ${coreutils}/bin/cat ${path} > ${to}
        dir=$(${coreutils}/bin/dirname ${to})
        name=$(${coreutils}/bin/basename ${to})
        ${coreutils}/bin/echo ${to}:${mode} >> .permissions
  '';

in

{
  install = install;
  mkdir = mkdir;
  copy = copy;
}