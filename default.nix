{stdenv, lib, libdot, pkgs, ...}:

with lib;

let
  hostname = lib.removeSuffix "\n" (builtins.readFile /etc/hostname);
  hostConfPath = "${(builtins.getEnv "HOME")}/.config/nixpkgs/hosts/${hostname}.nix";
  settings = if builtins.pathExists hostConfPath then import (hostConfPath) { inherit stdenv lib libdot pkgs; } else {};
  defaults = import ("${(builtins.getEnv "HOME")}/.config/nixpkgs/hosts/defaults.nix") { inherit stdenv lib libdot pkgs; };
  secretsConfPath = "${(builtins.getEnv "HOME")}/.secrets.nix";
  secrets = if builtins.pathExists secretsConfPath then import secretsConfPath else {};

in
  recursiveUpdate (recursiveUpdate (recursiveUpdate defaults settings) secrets) meta