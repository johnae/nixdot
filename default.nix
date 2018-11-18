{stdenv, lib, pkgs, ...}:

with lib;

let
  meta = import /etc/nixos/meta.nix;
  hostConfPath = "${(builtins.getEnv "HOME")}/.config/nixpkgs/hosts/${meta.hostName}.nix";
  settings = if builtins.pathExists hostConfPath then import (hostConfPath) { inherit stdenv lib pkgs; } else {};
  defaults = import ("${(builtins.getEnv "HOME")}/.config/nixpkgs/hosts/defaults.nix") { inherit stdenv lib pkgs; };
  secretsConfPath = "${(builtins.getEnv "HOME")}/.secrets.nix";
  secrets = if builtins.pathExists secretsConfPath then import secretsConfPath else {};

in
  recursiveUpdate (recursiveUpdate (recursiveUpdate defaults settings) secrets) meta