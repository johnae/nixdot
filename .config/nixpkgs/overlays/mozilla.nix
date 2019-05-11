let
  meta = builtins.fromJSON (builtins.readFile ./mozilla.json);
in
  import (builtins.fetchGit {
    inherit (meta) url rev;
  })
#import (builtins.fetchGit {
#    url = "https://github.com/mozilla/nixpkgs-mozilla.git";
#    ref = "master";
#    rev = "50bae918794d3c283aeb335b209efd71e75e3954";
#})