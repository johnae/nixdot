{lib}:

with lib;

let
  meta = import /etc/nixos/meta.nix;
  hostConfPath = "${(builtins.getEnv "HOME")}/.config/nixpkgs/hosts/${meta.hostName}.nix";
  settings = if builtins.pathExists hostConfPath then import hostConfPath else {};
  defaults = import "${(builtins.getEnv "HOME")}/.config/nixpkgs/hosts/defaults.nix";
  secretsConfPath = "${(builtins.getEnv "HOME")}/.secrets.nix";
  secrets = if builtins.pathExists secretsConfPath then import secretsConfPath else {};

in
  recursiveUpdate (recursiveUpdate defaults settings) secrets