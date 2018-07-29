self: super: {
  gometalinter = super.callPackage ../packages/gometalinter { };

  deadcode = super.callPackage ../packages/gometalinter/linters/deadcode { };
  errcheck = super.callPackage ../packages/gometalinter/linters/errcheck { };
  gas = super.callPackage ../packages/gometalinter/linters/gas { };
  goconst = super.callPackage ../packages/gometalinter/linters/goconst { };
  gocyclo = super.callPackage ../packages/gometalinter/linters/gocyclo { };
  ineffassign = super.callPackage ../packages/gometalinter/linters/ineffassign { };
  interfacer = super.callPackage ../packages/gometalinter/linters/interfacer { };
  maligned = super.callPackage ../packages/gometalinter/linters/maligned { };
  megacheck = super.callPackage ../packages/gometalinter/linters/megacheck { };
  structcheck = super.callPackage ../packages/gometalinter/linters/structcheck { };
  unconvert = super.callPackage ../packages/gometalinter/linters/unconvert { };
  govet = super.callPackage ../packages/gometalinter/linters/govet { };
  golint = super.callPackage ../packages/gometalinter/linters/golint { };
}
