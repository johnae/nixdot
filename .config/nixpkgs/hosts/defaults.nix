{stdenv, lib, libdot, pkgs, ...}:

let
  hostname = lib.removeSuffix "\n" (builtins.readFile /etc/hostname);
  theme = {
    base00 = "#2E3440"; # polar night
    base01 = "#3B4252"; # polar night
    base02 = "#434C5E"; # polar night
    base03 = "#4C566A"; # polar night
    base04 = "#D8DEE9"; # snow storm
    base05 = "#E5E9F0"; # snow storm
    base06 = "#ECEFF4"; # snow storm
    base07 = "#8FBCBB"; # frost
    base08 = "#88C0D0"; # frost
    base09 = "#81A1C1"; # frost
    base0A = "#5E81AC"; # frost
    base0B = "#BF616A"; # aurora
    base0C = "#D08770"; # aurora
    base0D = "#EBCB8B"; # aurora
    base0E = "#A3BE8C"; # aurora
    base0F = "#B48EAD"; # aurora
  };
  cnotation = hex: builtins.replaceStrings ["#"] ["0x"] hex;
in
rec {

  inherit theme;
  default-slackws = "karmalicious";

  program-symbols = rec {
    firefox = "";
    chrome = "";
    chromium = chrome;
    browse-chromium = chrome;
    browse = firefox;
    terminal = "";
    term = terminal;
    alacritty = terminal;
    termite = terminal;
    music = "";
    spotify = music;
    spotifyweb = music;
    editor = "";
    edit = editor;
    edi = editor;
    slack = "";
    slacks = slack;
    inbox = "";
    mail = inbox;
    image = "";
    gimp = image;
    astronaut = "";
    nautilus = astronaut;
    gedit = "";
  };

  starship = {
    kubernetes = {
      style = "bold blue";
      disabled = false;
    };
    nix_shell = {
      disabled = false;
      use_name = true;
    };
    rust = {
      symbol = " ";
    };
    git_branch = {
      symbol = " ";
    };
    package = {
      symbol = " ";
    };
  };

  spotifyd = rec {
    username = "binx";
    password_cmd = "${pkgs.pass}/bin/pass show web/spotify.com/${username}";
    backend = "pulseaudio";
    mixer = "PCM";
    volume-control = "alsa";
    device_name = hostname;
    bitrate = 320;
    cache_path = "${builtins.getEnv "HOME"}/.cache/spotifyd";
    volume-normalisation = true;
    normalisation-pregain = "-10";
  };

  services = {
    lorri = {
      Unit = {
        Description = "Lorri user nix-shell daemon";
      };
      Service = {
         ExecStart = "${pkgs.lorri}/bin/lorri daemon";
         Restart = "always";
         RestartSec = 3;
      };
    };
    spotifyd = {
      Unit = {
        Description = "Spotifyd - background music";
        Wants = [ "network-online.target" ];
        After = [ "network-online.target" ];
      };
      Service = {
         ExecStart = "${pkgs.spotifyd}/bin/spotifyd --no-daemon";
         Restart = "always";
         RestartSec = 3;
      };
    };
    spotnix = {
      Unit = {
        Description = "Spotify for UNIX";
        Wants = [ "spotifyd.service" ];
        After = [ "spotifyd.service" ];
      };
      Service = {
         ExecStart = ''
           ${stdenv.shell} -c 'CLIENT_ID="$(${pkgs.pass}/bin/pass web/spotify.com/spotnix | head -1)" CLIENT_SECRET="$(${pkgs.pass}/bin/pass web/spotify.com/spotnix | tail -1)" REDIRECT_URI="http://localhost:8182/spotnix" ${pkgs.spotnix}/bin/spotnix -d ${hostname} -e $XDG_RUNTIME_DIR/spotnix_event -i $XDG_RUNTIME_DIR/spotnix_input -o $XDG_RUNTIME_DIR/spotnix_output -r 10'
         '';
         Restart = "always";
         RestartSec = 3;
      };
    };
  };

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
          imapaccount = "insane-gmail";
          host = "imap.gmail.com";
          user = "john@insane.se";
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

    ];
  };

  dconf = {
    "org/gnome/desktop/interface" = {
      font-name = "Roboto Medium 11";
      icon-theme = "Arc";
      gtk-theme = "Arc-Dark";
    };
    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = "Roboto Medium 11";
      theme = "Arc-Dark";
    };
  };

  gtk-light-theme = "Arc";

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
    font = "JetBrains Mono";
    fontSize = "14.0";
    largeFontSize = "28.0";
    backgroundOpacity = "0.95";

    colors = ''
      colors:
        primary:
          background: '0x00374e' ## special - not part of theme
          foreground: '${cnotation theme.base04}'
        cursor:
          text: '${cnotation theme.base00}'
          cursor: '${cnotation theme.base04}'
        normal:
          black: '${cnotation theme.base01}'
          red: '${cnotation theme.base0B}'
          green: '${cnotation theme.base0E}'
          yellow: '${cnotation theme.base0D}'
          blue: '${cnotation theme.base09}'
          magenta: '${cnotation theme.base0F}'
          cyan: '${cnotation theme.base08}'
          white: '${cnotation theme.base05}'
        bright:
          black: '${cnotation theme.base03}'
          red: '${cnotation theme.base0B}'
          green: '${cnotation theme.base0E}'
          yellow: '${cnotation theme.base0D}'
          blue: '${cnotation theme.base09}'
          magenta: '${cnotation theme.base0F}'
          cyan: '${cnotation theme.base07}'
          white: '${cnotation theme.base06}'    '';
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

  mako-config = {
    font = "Roboto";
    background-color = "#000021DD";
    text-color = "#FFFFFFFF";
    border-size = "0";
    border-radius = "15";
    icons = "1";
    icon-path = "${pkgs.moka-icon-theme}/share/icons/Moka";
    markup = "1";
    actions = "1";
    default-timeout = "3000"; ## ms
    padding = "20";
    height = "200";
    width = "500";
    layer = "overlay";
  };

  sway = rec {
    mod = "Mod4";

    fontSize = "10";
    font = "pango:Roboto, 'Font Awesome 5 Free', 'Font Awesome 5 Brands', Arial, sans-serif, Bold ${fontSize}";

    swaylockBackground = "~/Pictures/lockscreen.jpg";

    swaylockArgs = "-e -i ${swaylockBackground} -K -s fill --font Roboto --inside-color 00000066 --inside-clear-color 00660099 --inside-ver-color 00006699 --inside-wrong-color 66000099 --key-hl-color FFFFFF99 --ring-color GGGGGGBB --ring-wrong-color FF6666BB --ring-ver-color 6666FFBB --text-color FFFFFFFF --text-clear-color FFFFFFFF --text-wrong-color FFFFFFFF --text-ver-color FFFFFFFF";

    swaylockTimeout = "300";
    swaylockSleepTimeout = "310";

    sway-outputs = {
      eDP-1 = "pos 0 0";
      "\"Unknown ASUS PB27U 0x0000C167\"" = "scale 1.5";
      "\"Unknown Q2790 GQMJ4HA000414\"" = "scale 1.0";
    };

    sway-inputs = {
      "*" = {
        #xkb_layout = "se";
        #xkb_variant = "mac";
        xkb_layout = "us";
        xkb_variant = ''""'';
        xkb_model = "pc105";
        xkb_options = "ctrl:nocaps,lv3:lalt_switch,compose:ralt,lv3:ralt_alt";
      };
      "2131:308:LEOPOLD_Mini_Keyboard" = {
        xkb_layout = "us";
        xkb_variant = ''""'';
        xkb_model = "pc105";
        xkb_options = "ctrl:nocaps,lv3:lalt_switch,compose:ralt,lv3:ralt_alt";
      };
    };

    to_client_config = colors: builtins.concatStringsSep "   " colors;

    client_focused_bg = "${theme.base0A}";
    client_focused_border = client_focused_bg;
    client_focused_indicator = client_focused_bg;
    client_focused_text = theme.base06;
    client_focused = to_client_config [
                                        client_focused_border
                                        client_focused_bg
                                        client_focused_text
                                        client_focused_indicator
                                        client_focused_indicator
                                      ];

    client_focused_inactive_bg = "${theme.base00}";
    client_focused_inactive_border = client_focused_inactive_bg;
    client_focused_inactive_indicator = client_focused_inactive_bg;
    client_focused_inactive_text = theme.base07;
    client_focused_inactive = to_client_config [
                                        client_focused_inactive_border
                                        client_focused_inactive_bg
                                        client_focused_inactive_text
                                        client_focused_inactive_indicator
                                        client_focused_inactive_indicator
                                      ];

    client_unfocused_bg = "${theme.base00}";
    client_unfocused_border = client_unfocused_bg;
    client_unfocused_indicator = client_unfocused_bg;
    client_unfocused_text = theme.base07;
    client_unfocused = to_client_config [
                                        client_unfocused_border
                                        client_unfocused_bg
                                        client_unfocused_text
                                        client_unfocused_indicator
                                        client_unfocused_indicator
                                      ];

    client_urgent_bg = "${theme.base0B}";
    client_urgent_border = client_urgent_bg;
    client_urgent_indicator = client_urgent_bg;
    client_urgent_text = theme.base05;
    client_urgent = to_client_config [
                                        client_urgent_border
                                        client_urgent_bg
                                        client_urgent_text
                                        client_urgent_indicator
                                        client_urgent_indicator
                                      ];

    bar = rec {
      height = "25";
      bgColor = "${theme.base00}DD";
      statuslineColor = theme.base08;
      separatorColor = theme.base01;

      focusedWorkspaceColorBorder = theme.base08;
      focusedWorkspaceColorBackground = theme.base08;
      focusedWorkspaceColorText = theme.base00;

      activeWorkspaceColorBorder = "${theme.base03}DD";
      activeWorkspaceColorBackground = "${theme.base03}DD";
      activeWorkspaceColorText = theme.base04;

      inactiveWorkspaceColorBorder = "${theme.base01}DD";
      inactiveWorkspaceColorBackground = "${theme.base01}DD";
      inactiveWorkspaceColorText = theme.base05;

      urgentWorkspaceColorBorder = theme.base0F;
      urgentWorkspaceColorBackground = theme.base0F;
      urgentWorkspaceColorText = theme.base06;
    };

  };
}
