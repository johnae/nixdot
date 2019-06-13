let
  meta = builtins.fromJSON (builtins.readFile ./mozilla.json);
in
  import (builtins.fetchGit {
    inherit (meta) url rev;
  })