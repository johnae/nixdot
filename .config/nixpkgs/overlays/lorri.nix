let
  meta = builtins.fromJSON (builtins.readFile ./lorri.json);
in

self: super: {
  lorri = import (super.fetchFromGitHub meta) { };
}