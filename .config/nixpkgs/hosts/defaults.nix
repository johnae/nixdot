{stdenv, lib, pkgs, ...}:

{

  mbsync = {
    accounts = [
      rec {
        imapaccount = rec {
          imapaccount = "karma-gmail";
          host = "imap.gmail.com";
          user = "john@karma.life";
          passcmd = "${pkgs.gnupg}/bin/gpg2 -q --for-your-eyes-only --no-tty -d ~/.password-store/web/gmail.com/mbsync-john@karma.life.gpg";
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
          inbox = "${path}Inbox";
        };
        channels = [
          {
            channel = "sync-${imapaccount.imapaccount}-default";
            master = ":${imapstore.imapstore}:\"INBOX\"";
            slave = ":${maildirstore.maildirstore}:INBOX";
            patterns = "* ![Gmail]*";
            sync = "All";
            expunge = "Both";
          }
          {
            channel = "sync-${imapaccount.imapaccount}-sent";
            master = ":${imapstore.imapstore}:\"[Gmail]/Sent Mail\"";
            slave = ":${maildirstore.maildirstore}:sent";
            patterns = "* ![Gmail]*";
            create = "Slave";
            sync = "All";
            expunge = "Both";
          }
          {
            channel = "sync-${imapaccount.imapaccount}-trash";
            master = ":${imapstore.imapstore}:\"[Gmail]/Trash\"";
            slave = ":${maildirstore.maildirstore}:trash";
            patterns = "* ![Gmail]*";
            create = "Slave";
            sync = "All";
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
          imapaccount = "insane-gmail";
          host = "imap.gmail.com";
          user = "john@insane.se";
          passcmd = "${pkgs.gnupg}/bin/gpg2 -q --for-your-eyes-only --no-tty -d ~/.password-store/web/gmail.com/mbsync-john@insane.se.gpg";
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
          inbox = "${path}Inbox";
        };
        channels = [
          {
            channel = "sync-${imapaccount.imapaccount}-default";
            master = ":${imapstore.imapstore}:\"INBOX\"";
            slave = ":${maildirstore.maildirstore}:INBOX";
            patterns = "* ![Gmail]*";
            sync = "All";
            expunge = "Both";
          }
          {
            channel = "sync-${imapaccount.imapaccount}-sent";
            master = ":${imapstore.imapstore}:\"[Gmail]/Sent Mail\"";
            slave = ":${maildirstore.maildirstore}:sent";
            patterns = "* ![Gmail]*";
            create = "Slave";
            sync = "All";
            expunge = "Both";
          }
          {
            channel = "sync-${imapaccount.imapaccount}-trash";
            master = ":${imapstore.imapstore}:\"[Gmail]/Trash\"";
            slave = ":${maildirstore.maildirstore}:trash";
            patterns = "* ![Gmail]*";
            create = "Slave";
            sync = "All";
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
    font = "Office Code Pro D";
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

  sway = rec {
    mod = "Mod4";

    fontSize = "10";
    font = "pango:Roboto, FontAwesome, Bold ${fontSize}";

    makoConfig = {
      font = "Roboto";
      backgroundColor = "#000021DD";
      borderSize = "0";
      defaultTimeout = "3000"; ## ms
      padding = "20";
      height = "200";
      width = "500";
    };

    swaylockArgs = "-e -i ~/Pictures/backgrounds/mountain-moon.jpg -s fill --font Roboto --inside-color 00000066 --inside-clear-color 00660099 --inside-ver-color 00006699 --inside-wrong-color 66000099 --key-hl-color FFFFFF99 --ring-color GGGGGGBB --ring-wrong-color FF6666BB --ring-ver-color 6666FFBB --text-color FFFFFFFF --text-clear-color FFFFFFFF --text-wrong-color FFFFFFFF --text-ver-color FFFFFFFF";

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

    barStatuslineColor = "#ffffff";
    barSeparatorColor = "#666666";

    barFocusedWorkspaceColorBorder = bgColor;
    barFocusedWorkspaceColorBackground = bgColor;
    barFocusedWorkspaceColorText = textColor;

    barActiveWorkspaceColorBorder = "#333333DD";
    barActiveWorkspaceColorBackground = "#5f676aDD";
    barActiveWorkspaceColorText = textColor;

    barInactiveWorkspaceColorBorder = "#000000DD";
    barInactiveWorkspaceColorBackground = barInactiveWorkspaceColorBorder;
    barInactiveWorkspaceColorText = inactiveTextColor;

    barUrgentWorkspaceColorBorder = urgentBgColor;
    barUrgentWorkspaceColorBackground = urgentBgColor;
    barUrgentWorkspaceColorText = textColor;

  };
}
