{stdenv, lib, ...}:

let

  install = xs: fun: lib.concatStringsSep "\n" (lib.concatMap (x: (lib.mapAttrsToList fun x.paths)) xs);


in

{
  install = install;
}