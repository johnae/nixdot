self: super: {
  gometalinter = super.callPackage ../packages/gometalinter/default.nix { };

  deadcode = super.callPackage ../packages/gometalinter/linters/deadcode/default.nix { };
  errcheck = super.callPackage ../packages/gometalinter/linters/errcheck/default.nix { };
  gas = super.callPackage ../packages/gometalinter/linters/gas/default.nix { };
  goconst = super.callPackage ../packages/gometalinter/linters/goconst/default.nix { };
  gocyclo = super.callPackage ../packages/gometalinter/linters/gocyclo/default.nix { };
  ineffassign = super.callPackage ../packages/gometalinter/linters/ineffassign/default.nix { };
  interfacer = super.callPackage ../packages/gometalinter/linters/interfacer/default.nix { };
  maligned = super.callPackage ../packages/gometalinter/linters/maligned/default.nix { };
  megacheck = super.callPackage ../packages/gometalinter/linters/megacheck/default.nix { };
  structcheck = super.callPackage ../packages/gometalinter/linters/structcheck/default.nix { };
  unconvert = super.callPackage ../packages/gometalinter/linters/unconvert/default.nix { };
  govet = super.callPackage ../packages/gometalinter/linters/govet/default.nix { };
  golint = super.callPackage ../packages/gometalinter/linters/golint/default.nix { };
}
