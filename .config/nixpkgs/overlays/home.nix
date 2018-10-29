self: super: {
  home = super.buildEnv {
    name = "home";
    paths = with self; [
          xdg_utils
          xwayland
          sway
          dotfiles
          my-emacs
          latest.firefox-beta-bin
          signal-desktop
          awscli
          my-google-cloud-sdk
          kubectl
          kubectx
          kubernetes-helm
          kustomize
          slack
          direnv
          playerctl
          _1password

          spotify
          mpv
          vlc

          gnome3.gedit
          libreoffice
          gimp
          inkscape
          evince
          imagemagick
          slack
          notify-desktop

          ii
          direnv

          python2Packages.docker_compose
          bc
          bat ## alias to cat = awesome

          acpi
          iw
          pass
          pinentry
          pinentry_gnome

          fzf
          stunnel
          ncdu
          zip

          gtk2
          gnome3.defaultIconTheme
          hicolor_icon_theme
          tango-icon-theme
          shared_mime_info
          arc-icon-theme
          papirus-icon-theme
          adapta-backgrounds
          adapta-gtk-theme
          adapta-kde-theme

          gsimplecal
          gnome3.nautilus
          gnome3.sushi
          gnome3.dconf-editor
          gnome3.dconf
          lxappearance
          feh

          nix-prefetch-scripts
          nix-prefetch-github
          ctags
          global
          rtags
          stack

          alacritty
    ];
  };
}
