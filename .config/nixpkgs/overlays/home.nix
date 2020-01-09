self: super: {
  home = super.buildEnv {
    name = "home";
    paths = with self; [
          xdg_utils
          xwayland
          sway
          swayidle
          swaylock
          swaybg
          dotfiles
          mu
          alacritty
          isync
          my-emacs
          pandoc
          w3m
          latest.firefox-nightly-bin
          signal-desktop
          awscli
          google-cloud-sdk
          kubectl
          kubectx
          kubernetes-helm
          kustomize
          slack
          direnv
          playerctl
          _1password
          lorri
          rust-analyzer

          remmina
          evince

          spotify
          spotnix
          mpv
          vlc

          grim
          slurp

          steam

          wl-clipboard

          gnome3.gedit
          #gimp-with-plugins
          gimp
          inkscape
          evince
          imagemagick
          slack
          notify-desktop
          libnotify

          ii
          direnv

          docker_compose
          bc
          bat ## alias to cat = awesome
          gotop

          acpi
          iw
          pass
          pinentry_gnome

          fzf
          skim
          stunnel
          ncdu
          zip
          gitAndTools.hub

          gtk2
          gnome3.defaultIconTheme
          hicolor_icon_theme
          tango-icon-theme
          shared_mime_info
          arc-icon-theme
          arc-theme
          arc-kde-theme
          papirus-icon-theme
          adapta-backgrounds
          adapta-gtk-theme
          adapta-kde-theme
          nordic
          nordic-polar

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
    ];
  };
}
