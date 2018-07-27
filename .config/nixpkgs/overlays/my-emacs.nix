self: super: {
  my-emacs = self.callPackage ../packages/my-emacs/default.nix { };
}
