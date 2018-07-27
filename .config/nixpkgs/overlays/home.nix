self: super: {
  home = self.buildEnv {
    name = "home";
    paths = with self; [
          dotfiles
          my-emacs
          latest.firefox-beta-bin
          dropbox
          signal-desktop
          awscli
          my-google-cloud-sdk
          slack
          direnv
    ];
  };
}
