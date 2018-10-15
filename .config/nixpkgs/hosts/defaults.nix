{
  dconf = {
    "org/gnome/desktop/interface" = {
      font-name = "Roboto Medium 11";
      icon-theme = "Papirus-Adapta-Nokto";
      gtk-theme = "Adapta-Nokto";
    };
    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = "Roboto Medium 11";
      theme = "Adapta-Nokto";
    };
  };
  terminfo = {
    xterm-24bits = ''
      xterm-24bits|xterm with 24-bit direct color mode,
         use=xterm-256color,
         sitm=\E[3m,
         ritm=\E[23m,
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
    font = "Source Code Pro";
    fontSize = "8.0";
    largeFontSize = "20.0";
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

    swaylockArgs = "-e -i ~/Pictures/backgrounds/the-host.jpg -s fill --font Roboto --inside-color 00000066 --inside-clear-color 00660099 --inside-ver-color 00006699 --inside-wrong-color 66000099 --key-hl-color FFFFFF99 --ring-color GGGGGGBB --ring-wrong-color FF6666BB --ring-ver-color 6666FFBB --text-color FFFFFFFF --text-clear-color FFFFFFFF --text-wrong-color FFFFFFFF --text-ver-color FFFFFFFF";

    swaylockTimeout = "300";
    swaylockSleepTimeout = "600";

    sway-outputs = {
      "*" = "bg ~/Pictures/backgrounds/konsum.jpg fill";
      eDP-1 = "pos 0 0";
    };

    bgColor = "#4A90E2";
    borderColor = bgColor;
    inactiveBgColor = "#000000";
    textColor = "#fdf6e3";
    inactiveTextColor = "#839496";
    urgentBgColor = "#d24939";
    selectedColor = "#9999FF";
    indicatorColor = "#00ff00";

    barStatuslineColor = "#ffffff";
    barSeparatorColor = "#666666";

    barFocusedWorkspaceColorBorder = bgColor;
    barFocusedWorkspaceColorBackground = bgColor;
    barFocusedWorkspaceColorText = textColor;

    barActiveWorkspaceColorBorder = "#333333";
    barActiveWorkspaceColorBackground = "#5f676a";
    barActiveWorkspaceColorText = textColor;

    barInactiveWorkspaceColorBorder = inactiveBgColor;
    barInactiveWorkspaceColorBackground = inactiveBgColor;
    barInactiveWorkspaceColorText = inactiveTextColor;

    barUrgentWorkspaceColorBorder = urgentBgColor;
    barUrgentWorkspaceColorBackground = urgentBgColor;
    barUrgentWorkspaceColorText = textColor;

  };
}