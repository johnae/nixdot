{stdenv, lib, pkgs, ...}:

{

  mbsync = {
    accounts = [
      rec {
        imapaccount = rec {
          imapaccount = "karma-gmail";
          host = "imap.gmail.com";
          user = "john@karma.life";
          passcmd = "${pkgs.gnupg}/bin/gpg2 -q --for-your-eyes-only --no-tty -d " +
                    "~/.password-store/emacs/auth/authinfo.gpg | " +
                    "${pkgs.gawk}/bin/awk '/machine imap.gmail.com login ${user}/ {print $NF}'";
          ssltype = "IMAPS";
          certificatefile = "/etc/ssl/certs/ca-certificates.crt";
          pipelinedepth = 50;
        };
        imapstore = {
          imapstore = "${imapaccount.imapaccount}-remote";
          account = imapaccount.imapaccount;
        };
        maildirstore = rec {
          maildirstore = "${imapaccount.imapaccount}-local";
          subfolders = "Verbatim";
          path = "~/.mail/${imapaccount.imapaccount}/";
          inbox = "${path}inbox";
        };
        channels = [
          {
            channel = imapaccount.imapaccount;
            master = ":${imapstore.imapstore}:";
            slave = ":${maildirstore.maildirstore}:";
            patterns = "* ![Gmail]* \"[Gmail]/Sent Mail\" \"[Gmail]/All Mail\" \"[Gmail]/Trash\"";
            create = "Both";
            expunge = "Both";
            syncstate = "*";
            copyarrivaldate = "yes";
          }
        ];
        groups = [
          {
            group = imapaccount.imapaccount;
            channels = builtins.map (x: x.channel) channels;
          }
        ];
      }

      rec {
        imapaccount = rec {
          imapaccount = "insane-mail";
          host = "mail.insane.se";
          user = "john@insane.se";
          passcmd = "${pkgs.gnupg}/bin/gpg2 -q --for-your-eyes-only --no-tty -d " +
                    "~/.password-store/emacs/auth/authinfo.gpg | " +
                    "${pkgs.gawk}/bin/awk '/machine mail.insane.se login ${user} port 993/ {print $NF}'";
          ssltype = "IMAPS";
          certificatefile = "/etc/ssl/certs/ca-certificates.crt";
          pipelinedepth = 50;
        };
        imapstore = {
          imapstore = "${imapaccount.imapaccount}-remote";
          account = imapaccount.imapaccount;
        };
        maildirstore = rec {
          maildirstore = "${imapaccount.imapaccount}-local";
          subfolders = "Verbatim";
          path = "~/.mail/${imapaccount.imapaccount}/";
          inbox = "${path}inbox";
        };
        channels = [
          {
            channel = imapaccount.imapaccount;
            master = ":${imapstore.imapstore}:";
            slave = ":${maildirstore.maildirstore}:";
            patterns = "*";
            create = "Both";
            expunge = "Both";
            syncstate = "*";
            copyarrivaldate = "yes";
          }
        ];
        groups = [
          {
            group = imapaccount.imapaccount;
            channels = builtins.map (x: x.channel) channels;
          }
        ];
      }
    ];
  };

  dconf = {
    "org/gnome/desktop/interface" = {
      font-name = "Roboto Medium 11";
      icon-theme = "Papirus-Adapta-Nokto";
      gtk-theme = "Adapta-Nokto-Eta";
    };
    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = "Roboto Medium 11";
      theme = "Adapta-Nokto-Eta";
    };
  };

  gtk-light-theme = "Adapta-Eta";

  terminfo = {
    xterm-24bits = ''
      # Use colon separators.
      xterm-24bit|xterm with 24-bit direct color mode,
        use=xterm-256color,
        setb24=\E[48:2:%p1%{65536}%/%d:%p1%{256}%/%{255}%&%d:%p1%{255}%&%dm,
        setf24=\E[38:2:%p1%{65536}%/%d:%p1%{256}%/%{255}%&%d:%p1%{255}%&%dm,
      # Use semicolon separators.
      xterm-24bits|xterm with 24-bit direct color mode,
        use=xterm-256color,
        setb24=\E[48;2;%p1%{65536}%/%d;%p1%{256}%/%{255}%&%d;%p1%{255}%&%dm,
        setf24=\E[38;2;%p1%{65536}%/%d;%p1%{256}%/%{255}%&%d;%p1%{255}%&%dm,
    '';
  };

  ssh = {
    hosts = {
      "*" = {
        ControlMaster = "auto";
        ControlPath = "~/.ssh/master-%r@%h-%p";
        #ControlPersist = "600";
        ForwardAgent = "yes";
        ServerAliveInterval = "60";
      };
      "*.compute.amazonaws.com" = {
        StrictHostKeyChecking = "no";
        UserKnownHostsFile = "/dev/null";
      };
      "git-codecommit.*.amazonaws.com" = {
        User = "APKAIZ3MXXINRIYQBXKA";
        PreferredAuthentications = "publickey";
      };
      "github github.com" = {
        User = "git";
        Hostname = "github.com";
        PreferredAuthentications = "publickey";
      };
    };
  };

  git = {
    signingKey = "0x04ED6F42C62F42E9";
    fullName = "John Axel Eriksson";
    email = "john@insane.se";
  };

  alacritty = {
    font = "Office Code Pro D Nerd Font";
    fontSize = "14.0";
    largeFontSize = "28.0";
    backgroundOpacity = "0.95";
    colors = ''
      # Copyright (c) 2017-present Arctic Ice Studio <development@arcticicestudio.com>
      # Copyright (c) 2017-present Sven Greb <code@svengreb.de>

      # Project:    Nord Alacritty
      # Version:    0.1.0
      # Repository: https://github.com/arcticicestudio/nord-alacritty
      # License:    MIT
      # References:
      #   https://github.com/jwilm/alacritty
      # background: '0x006e8a'
      # background: '0x2E3440'

      colors:
        primary:
          background: '0x00374e'
          foreground: '0xD8DEE9'
        cursor:
          text: '0x2E3440'
          cursor: '0xD8DEE9'
        normal:
          black: '0x3B4252'
          red: '0xBF616A'
          green: '0xA3BE8C'
          yellow: '0xEBCB8B'
          blue: '0x81A1C1'
          magenta: '0xB48EAD'
          cyan: '0x88C0D0'
          white: '0xE5E9F0'
        bright:
          black: '0x4C566A'
          red: '0xBF616A'
          green: '0xA3BE8C'
          yellow: '0xEBCB8B'
          blue: '0x81A1C1'
          magenta: '0xB48EAD'
          cyan: '0x8FBCBB'
          white: '0xECEFF4'    '';
  };

  xresources = {
    dpi = "96";
    rofiFont = "Roboto 18";
    rofiColorNormal = "#004b46,#fdf6e3,#004b46,#004b46,#9999FF";
    rofiColorWindow = "#004b46";
  };

  waybar = rec {
    default = {
      border = "none";
      border-radius = "0";
      font-family = "Roboto, 'Font Awesome 5 Free', 'Font Awesome 5 Brands', Arial, sans-serif";
      font-weight  = "900"; ## because reasons - font awesome doesn't display otherwise
      font-size = "13px";
      min-height = "0";
    };
  };

  sway = rec {
    mod = "Mod4";

    fontSize = "10";
    font = "pango:Roboto, 'Font Awesome 5 Free', 'Font Awesome 5 Brands', Arial, sans-serif, Bold ${fontSize}";

    makoConfig = {
      font = "Roboto";
      backgroundColor = "#000021DD";
      borderSize = "0";
      defaultTimeout = "3000"; ## ms
      padding = "20";
      height = "200";
      width = "500";
    };

    swaylockBackground = "~/Pictures/lockscreen.jpg";

    swaylockArgs = "-e -i ${swaylockBackground} -s fill --font Roboto --inside-color 00000066 --inside-clear-color 00660099 --inside-ver-color 00006699 --inside-wrong-color 66000099 --key-hl-color FFFFFF99 --ring-color GGGGGGBB --ring-wrong-color FF6666BB --ring-ver-color 6666FFBB --text-color FFFFFFFF --text-clear-color FFFFFFFF --text-wrong-color FFFFFFFF --text-ver-color FFFFFFFF";

    swaylockTimeout = "300";
    swaylockSleepTimeout = "310";

    sway-outputs = {
      eDP-1 = "pos 0 0";
    };

    sway-inputs = {
      "*" = {
        xkb_layout = "se";
        xkb_variant = "mac";
        xkb_model = "pc105";
        xkb_options = "ctrl:nocaps,lv3:lalt_switch,compose:ralt,lv3:ralt_alt";
      };
    };

    bgColor = "#4A90E2FF";
    inactiveBgColor = "#000000FF";
    textColor = "#fdf6e3";
    inactiveTextColor = "#839496";
    urgentBgColor = "#d24939FF";
    selectedColor = "#9999FF";
    indicatorColor = "#00ff00";

    bar = rec {
      height = "25";
      bgColor = "#222244CD";
      statuslineColor = "#ffffff";
      separatorColor = "#666666";

      focusedWorkspaceColorBorder = bgColor;
      focusedWorkspaceColorBackground = bgColor;
      focusedWorkspaceColorText = "#fdf6e3";

      activeWorkspaceColorBorder = bgColor;
      activeWorkspaceColorBackground = bgColor;
      activeWorkspaceColorText = "#e8e375";

      inactiveWorkspaceColorBorder = bgColor;
      inactiveWorkspaceColorBackground = bgColor;
      inactiveWorkspaceColorText = "#aaaaaa";

      urgentWorkspaceColorBorder = bgColor;
      urgentWorkspaceColorBackground = bgColor;
      urgentWorkspaceColorText = "#e8e375";
    };

  };
}
