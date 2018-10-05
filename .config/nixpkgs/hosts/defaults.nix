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