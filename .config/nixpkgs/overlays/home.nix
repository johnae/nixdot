self: super: {
  home = super.buildEnv {
    name = "home";
    paths = with self; [
          dotfiles
          my-emacs
          latest.firefox-beta-bin
          signal-desktop
          awscli
          my-google-cloud-sdk
          slack
          direnv
          playerctl
    ];
  };
}
