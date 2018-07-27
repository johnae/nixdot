self: super: {
  gometalinter = self.callPackage ../packages/gometalinter/default.nix { };

  deadcode = self.callPackage ../packages/gometalinter/linters/deadcode/default.nix { };
  errcheck = self.callPackage ../packages/gometalinter/linters/errcheck/default.nix { };
  gas = self.callPackage ../packages/gometalinter/linters/gas/default.nix { };
  goconst = self.callPackage ../packages/gometalinter/linters/goconst/default.nix { };
  gocyclo = self.callPackage ../packages/gometalinter/linters/gocyclo/default.nix { };
  ineffassign = self.callPackage ../packages/gometalinter/linters/ineffassign/default.nix { };
  interfacer = self.callPackage ../packages/gometalinter/linters/interfacer/default.nix { };
  maligned = self.callPackage ../packages/gometalinter/linters/maligned/default.nix { };
  megacheck = self.callPackage ../packages/gometalinter/linters/megacheck/default.nix { };
  structcheck = self.callPackage ../packages/gometalinter/linters/structcheck/default.nix { };
  unconvert = self.callPackage ../packages/gometalinter/linters/unconvert/default.nix { };
  govet = self.callPackage ../packages/gometalinter/linters/govet/default.nix { };
  golint = self.callPackage ../packages/gometalinter/linters/golint/default.nix { };
}
