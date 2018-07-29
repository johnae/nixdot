self: super: {
  my-emacs = super.callPackage ../packages/my-emacs/default.nix { };
}
