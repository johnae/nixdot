{
 stdenv, lib,
 writeScriptBin,
 writeStrictShellScriptBin,
 my-emacs, termite, wl-clipboard,
 ps, jq, fire, sway, rofi,
 fd, fzf, bashInteractive,
 pass, wpa_supplicant,
 gnupg, gawk, gnused,
 gnugrep, findutils, coreutils,
 alacritty, libnotify, xdotool,
 maim, slop, feh, killall,
 openssh, kubectl, xorg,
 browser, settings,
 ...}:

let
  emacsclient = "${my-emacs}/bin/emacsclient";
  emacs = "${my-emacs}/bin/emacs";

  emacs-server = writeStrictShellScriptBin "emacs-server" ''
    if [ -e /run/user/1337/emacs1337/server ]; then
       exit 0
    fi
    ${coreutils}/bin/rm -rf /run/user/1337/emacs1337
    TMPDIR=/run/user/1337 exec ${emacs} --daemon=server
  '';

  edit = writeStrictShellScriptBin "edit" ''
    ${emacs-server}/bin/emacs-server
    exec ${emacsclient} -n -c \
         -s /run/user/1337/emacs1337/server "$@" >/dev/null 2>&1
  '';

  edi = writeStrictShellScriptBin "edi" ''
    ${emacs-server}/bin/emacs-server
    export TERM=xterm-24bits
    exec ${emacsclient} -t -s /run/user/1337/emacs1337/server "$@"
  '';

  ed = writeStrictShellScriptBin "ed" ''
    ${emacs-server}/bin/emacs-server
    exec ${emacsclient} -c -s /run/user/1337/emacs1337/server "$@" >/dev/null 2>&1
  '';

  fzf-fzf = writeStrictShellScriptBin "fzf-fzf" ''
    FZF_MIN_HEIGHT=''${FZF_MIN_HEIGHT:-100}
    FZF_MARGIN=''${FZF_MARGIN:-5,5,5,5}
    FZF_PROMPT=''${FZF_PROMPT:- >}
    export FZF_DEFAULT_OPTS=''${FZF_OPTS:-"--reverse"}
    exec ${fzf}/bin/fzf --min-height="$FZF_MIN_HEIGHT" \
        --margin="$FZF_MARGIN" \
        --prompt="$FZF_PROMPT"
  '';

  project-select = writeStrictShellScriptBin "project-select" ''
    projects=$*
    if [ -z "$projects" ]; then
      ${coreutils}/bin/echo "Please provide the project root directories to search as arguments"
      exit 1
    fi
    export FZF_PROMPT="goto project >"
    export FZF_OPTS="--tac --reverse"
    ${fd}/bin/fd -d 8 -pHI -t f '.*\.git/config$' "$projects" | \
      ${gnused}/bin/sed 's|/\.git/config||g' | \
      ${gnused}/bin/sed "s|$HOME/||g" | \
      ${fzf-fzf}/bin/fzf-fzf | \
      ${findutils}/bin/xargs -I{} ${coreutils}/bin/echo "$HOME/{}"
  '';

  screenshot = writeStrictShellScriptBin "screenshot" ''
    name=$(${coreutils}/bin/date +%Y-%m-%d_%H:%M:%S_screen)
    output_dir=$HOME/Pictures/screenshots
    fmt=png
    ${coreutils}/bin/mkdir -p "$output_dir"
    #killall compton
    ${maim}/bin/maim -s --format="$fmt $output_dir/$name.$fmt"
  '';

  browse = writeStrictShellScriptBin "browse" ''
    exec ${browser} -P default
  '';

  slacks = writeStrictShellScriptBin "slacks" ''
    WS=''${1:-}
    if [ -z "$WS" ]; then
      echo Please provide a workspace as argument
      exit 1
    fi
    exec ${browser} --new-instance -P slack --new-window "https://$WS.slack.com"
  '';

  spotifyweb = writeStrictShellScriptBin "spotifyweb" ''
    exec ${browser} --new-instance -P spotify --new-window "https://open.spotify.com"
  '';

  terminal = writeStrictShellScriptBin "terminal" ''
    _TERMEMU=''${_TERMEMU:-}
    TERMINAL_CONFIG=''${TERMINAL_CONFIG:-}
    if [ "$_TERMEMU" = "termite" ]; then
      CONFIG=$HOME/.config/termite/config$TERMINAL_CONFIG
      ${termite}/bin/termite --config "$CONFIG" "$@"
    else
      CONFIG=$HOME/.config/alacritty/alacritty$TERMINAL_CONFIG.yml
      ${if builtins.hasAttr "WINIT_HIDPI_FACTOR" settings then
      "export WINIT_HIDPI_FACTOR=${settings.WINIT_HIDPI_FACTOR}"
      else ""}
      ${alacritty}/bin/alacritty --config-file "$CONFIG" "$@"
    fi
  '';

  launch = writeStrictShellScriptBin "launch" ''
    cmd=$*
    _SET_WS_NAME=''${_SET_WS_NAME:-}
    _USE_NAME=''${_USE_NAME:-}
    if [ -z "$cmd" ]; then
      read -r cmd
    fi
    MSG=${sway}/bin/swaymsg
    if [ "$_SET_WS_NAME" = "y" ]; then
      name=$(${coreutils}/bin/echo "$cmd" | ${gawk}/bin/awk '{print $1}')
      if [ "$_USE_NAME" ]; then
          name=$_USE_NAME
      fi
      echo "$name"
      wsname=$($MSG -t get_workspaces | ${jq}/bin/jq -r \
               '.[] | select(.focused==true).name')
      if ${coreutils}/bin/echo "$wsname" | \
         ${gnugrep}/bin/grep -E '^[0-9]:? ?+$' > /dev/null; then
        $MSG "rename workspace to \"$wsname: $name\"" >/dev/null 2>&1
      fi
    fi
    echo "${fire}/bin/fire $cmd" | ${stdenv.shell}
  '';

  rename-workspace = writeStrictShellScriptBin "rename-workspace" ''
    CMD=${sway}/bin/swaymsg
    WSNUM=$($CMD -t get_workspaces | ${jq}/bin/jq \
            '.[] | select(.focused==true).name' | \
            ${coreutils}/bin/cut -d"\"" -f2 | \
            ${gnugrep}/bin/grep -o -E '[[:digit:]]+')
    if [ -z "$*" ]; then
        exit 0
    fi
    $CMD "rename workspace to \"$WSNUM: $*\"" >/dev/null 2>&1
  '';

  fzf-run = writeScriptBin "fzf-run" ''
    #!${bashInteractive}/bin/bash
    export FZF_PROMPT="run >> "
    export _SET_WS_NAME=y
    export FZF_OPTS="--no-bold --no-color --height=40 --no-hscroll --no-mouse --no-extended --print-query --reverse --tac"

    compgen -c | \
    sort -u | \
    ${gawk}/bin/awk '{ if (length($0) > 2) print }' | \
    ${gnugrep}/bin/grep -v -E '^\..*' | \
    fzf-fzf | \
    tail -n1 | \
    ${findutils}/bin/xargs -r ${launch}/bin/launch
  '';

  fzf-window = writeStrictShellScriptBin "fzf-window" ''
    cmd=''${1:-}
    if [ -z "$cmd" ]; then
      echo "Please provide a command to run in the window as the argument"
      exit 1
    fi
    shift
    export _TERMEMU=termite
    export TERMINAL_CONFIG=-launcher
    if ${ps}/bin/ps aux | ${gnugrep}/bin/grep '\-t fzf-window' | \
       ${gnugrep}/bin/grep -v grep > /dev/null 2>&1; then
        ${ps}/bin/ps aux | \
            ${gnugrep}/bin/grep '\-t fzf-window' | \
            ${gnugrep}/bin/grep -v grep | \
            ${gawk}/bin/awk '{print $2}' | \
            ${findutils}/bin/xargs -r -I{} kill {}
        exit
    fi

    exec terminal -t "fzf-window" -e "$cmd $*"
  '';

  fzf-passmenu = writeStrictShellScriptBin "fzf-passmenu" ''
    export _TERMEMU=termite
    export FZF_PROMPT="copy password >> "
    export FZF_OPTS="--no-bold --no-color --height=40 --reverse --no-hscroll --no-mouse"
    ## because bug: https://github.com/jordansissel/xdotool/issues/49

    passfile=''${1:-}
    nosubmit=''${nosubmit:-}
    passonly=''${passonly:-}
    _passmenu_didsearch=''${_passmenu_didsearch:-}
    SWAYSOCK=''${SWAYSOCK:-}
    prefix=$(readlink -f "$HOME/.password-store")
    if [ -z "$_passmenu_didsearch" ]; then
      export _passmenu_didsearch=y
      ${fd}/bin/fd --type f -E '/notes/' '.gpg$' "$HOME/.password-store" | \
         ${gnused}/bin/sed "s|$prefix/||g" | ${gnused}/bin/sed 's|.gpg$||g' | \
         ${fzf-fzf}/bin/fzf-fzf | \
         ${findutils}/bin/xargs -r -I{} ${coreutils}/bin/echo "$0 {}" | \
         ${launch}/bin/launch
    fi

    if [ "$passfile" = "" ]; then
      exit
    fi

    error_icon=~/Pictures/icons/essential/error.svg

    getlogin() {
      ${coreutils}/bin/echo -n "$(${coreutils}/bin/basename "$1")"
    }

    getpass() {
      ${coreutils}/bin/echo -n "$(${gnupg}/bin/gpg --decrypt "$prefix/$1.gpg" \
                            2>/dev/null | ${coreutils}/bin/head -1)"
    }

    login=$(getlogin "$passfile")
    pass=$(getpass "$passfile")

    if [ "$pass" = "" ]; then
      ${libnotify}/bin/notify-send -i $error_icon -a "Password store" -u critical \
      "Decrypt error" "Error decrypting password file, is your gpg card inserted?"
    else
      if [ -z "$SWAYSOCK" ]; then
        if [ -z "$passonly" ]; then
          ${coreutils}/bin/echo -n "$login" | ${xdotool}/bin/xdotool type \
                                            --clearmodifiers --file -
          ${xdotool}/bin/xdotool key Tab
        fi
        ${coreutils}/bin/echo -n "$pass" | ${xdotool}/bin/xdotool type \
                                         --clearmodifiers --file -
        if [ -z "$nosubmit" ]; then
          ${xdotool}/bin/xdotool key Return
        fi
      else
          ${coreutils}/bin/echo -n "$pass" | ${wl-clipboard}/bin/wl-copy
      fi
    fi

  '';

  rofi-passmenu = writeStrictShellScriptBin "rofi-passmenu" ''
    PROMPT=" for password >"

    prefix=$(readlink -f "$HOME/.password-store")
    nosubmit=''${nosubmit:-}
    passonly=''${passonly:-}
    passfile=$(${fd}/bin/fd --type f -E '/notes/' '.gpg$' "$HOME/.password-store" | \
       ${gnused}/bin/sed "s|$prefix/||g" | ${gnused}/bin/sed 's|.gpg$||g' | \
       ${rofi}/bin/rofi -dmenu -p "$PROMPT")

    if [ "$passfile" = "" ]; then
      exit
    fi

    error_icon=~/Pictures/icons/essential/error.svg

    getlogin() {
      ${coreutils}/bin/echo -n "$(${coreutils}/bin/basename "$1")"
    }

    getpass() {
      ${coreutils}/bin/echo -n "$(${gnupg}/bin/gpg \
          --decrypt "$prefix/$1.gpg" 2>/dev/null | ${coreutils}/bin/head -1)"
    }

    login=$(getlogin "$passfile")
    pass=$(getpass "$passfile")

    if [ "$pass" = "" ]; then
      ${libnotify}/bin/notify-send -i $error_icon -a "Password store" -u critical \
      "Decrypt error" "Error decrypting password file, is your gpg card inserted?"
    else
      if [ -z "$SWAYSOCK" ]; then
        if [ -z "$passonly" ]; then
          ${coreutils}/bin/echo -n "$login" | ${xdotool}/bin/xdotool type \
                                            --clearmodifiers --file -
          ${xdotool}/bin/xdotool key Tab
        fi
        ${coreutils}/bin/echo -n "$pass" | ${xdotool}/bin/xdotool type \
                                         --clearmodifiers --file -
        if [ -z "$nosubmit" ]; then
          ${xdotool}/bin/xdotool key Return
        fi
      else
          ${coreutils}/bin/echo -n "$pass" | ${wl-clipboard}/bin/wl-copy
      fi
    fi
  '';

  update-wifi-networks = writeStrictShellScriptBin "update-wifi-networks" ''
    IFS=$'\n'
    for NET in $(find ~/.password-store/wifi/networks/ -print0 -type f | xargs -I{} basename {}); do
      NETNAME=$(basename "$NET" .gpg)
      echo "Ensure wireless network \"$NETNAME\" is available"
      ${pass}/bin/pass show "wifi/networks/$NETNAME" | sudo tee "/var/lib/iwd/$NETNAME.psk" > /dev/null
    done
  '';

  add-wifi-network = writeStrictShellScriptBin "add-wifi-network" ''
    NET=''${1:-}
    PASS=''${2:-}
    if [ -z "$NET" ]; then
      echo Please provide the network as first argument
      exit 1
    fi
    if [ -z "$PASS" ]; then
      echo Please provide the password as second argument
      exit 1
    fi
    PSK=$(${wpa_supplicant}/bin/wpa_passphrase "$1" "$2" | grep "[^#]psk=" | awk -F'=' '{print $2}')
    if [ -z "$PSK" ]; then
      echo Hmm PSK was empty
      exit 1
    fi
    cat <<EOF | ${pass}/bin/pass insert "wifi/networks/$NET"
    [Security]
    PreSharedKey=$PSK
    Passphrase=$PASS
    EOF
    ${update-wifi-networks}/bin/update-wifi-networks
  '';

  autorandr-postswitch = writeStrictShellScriptBin "autorandr-postswitch" ''
    BG=$(${gnugrep}/bin/grep dmBackground < /etc/nixos/meta.nix | \
         ${gawk}/bin/awk '{print $3}' | ${gnused}/bin/sed 's|[";]||g')
    ${killall}/bin/killall compton
    ${coreutils}/bin/echo "Setting background: '$BG'"
    if [ -e "$BG" ]; then
       ${feh}/bin/feh --bg-fill "$BG"
    fi

  '';

  random-background = writeStrictShellScriptBin "random-background" ''
    ${findutils}/bin/find "$HOME/Pictures/backgrounds" -type f | \
         ${coreutils}/bin/sort -R | ${coreutils}/bin/head -1
  '';

  start-sway = writeStrictShellScriptBin "start-sway" ''
    export _TERMEMU=termite
    export XDG_SESSION_TYPE=wayland
    export XKB_DEFAULT_LAYOUT=se
    export XKB_DEFAULT_VARIANT=mac
    export XKB_DEFAULT_MODEL=pc105
    export XKB_DEFAULT_OPTIONS=ctrl:nocaps,lv3:lalt_switch,compose:ralt,lv3:ralt_alt

    export GDK_BACKEND=wayland
    export GTK_THEME="${settings.dconf."org/gnome/desktop/interface".gtk-theme}"
    export QT_STYLE_OVERRIDE=gtk
    export _JAVA_AWT_WM_NONREPARENTING=1
    export VISUAL=edi
    export EDITOR=$VISUAL
    export PROJECTS=~/Development
    if [ -e .config/syncthing/config.xml ]; then
       SYNCTHING_API_KEY=$(grep apikey < .config/syncthing/config.xml | \
                                awk -F">|</" '{print $2}')
       if [ "$SYNCTHING_API_KEY" != "" ]; then
          export SYNCTHING_API_KEY
       fi
    fi

    exec dbus-launch --exit-with-session sway "$@"
  '';

in

  {
    paths = {
      inherit edit edi ed
              emacs-server
              fzf-fzf project-select
              terminal launch
              fzf-passmenu rofi-passmenu
              fzf-run fzf-window
              browse slacks spotifyweb
              rename-workspace screenshot
              autorandr-postswitch
              start-sway random-background
              add-wifi-network update-wifi-networks;
    };
  }
