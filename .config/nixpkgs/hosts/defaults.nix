{
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
    fontSize = "14.0";
    largeFontSize = "28.0";
    backgroundOpacity = "0.95";
    colors = ''
      # Base16 Solarized Dark 256 - alacritty color config
      # Ethan Schoonover (http://ethanschoonover.com/solarized)
      colors:
        # Default colors
        primary:
          background: '0x002b36'
          foreground: '0x93a1a1'

        # Colors the cursor will use if `custom_cursor_colors` is true
        cursor:
          text: '0x002b36'
          cursor: '0x93a1a1'

        # Normal colors
        normal:
          black:   '0x002b36'
          red:     '0xdc322f'
          green:   '0x859900'
          yellow:  '0xb58900'
          blue:    '0x268bd2'
          magenta: '0x6c71c4'
          cyan:    '0x2aa198'
          white:   '0x93a1a1'

        # Bright colors
        bright:
          black:   '0x657b83'
          red:     '0xdc322f'
          green:   '0x859900'
          yellow:  '0xb58900'
          blue:    '0x268bd2'
          magenta: '0x6c71c4'
          cyan:    '0x2aa198'
          white:   '0x93a1a1'
    '';
  };

  xresources = {
    dpi = "96";
    rofiFont = "Roboto 18";
    rofiColorNormal = "#004b46,#fdf6e3,#004b46,#004b46,#9999FF";
    rofiColorWindow = "#004b46";
  };

  i3 = rec {
    mod = "Mod4";

    fontSize = "10";
    font = "pango:Roboto, FontAwesome, Bold ${fontSize}";

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