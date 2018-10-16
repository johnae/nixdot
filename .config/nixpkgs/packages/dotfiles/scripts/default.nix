{
 stdenv,
 writeScriptBin,
 my-emacs, termite, wl-clipboard,
 ps, jq, fire, sway, rofi,
 fd, fzf, bashInteractive,
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

  emacs-server = writeScriptBin "emacs-server" ''
    #!${stdenv.shell}
    if [ "$1" = "" -a -e /run/user/1337/emacs1337/server ]; then
       exit 0
    fi
    ${coreutils}/bin/rm -rf /run/user/1337/emacs1337
    TMPDIR=/run/user/1337 exec ${emacs} --daemon=server
  '';

  edit = writeScriptBin "edit" ''
    #!${stdenv.shell}
    ${emacs-server}/bin/emacs-server
    exec ${emacsclient} -n -c -s /run/user/1337/emacs1337/server $@ 2>&1 >/dev/null
  '';

  edi = writeScriptBin "edi" ''
    #!${stdenv.shell}
    ${emacs-server}/bin/emacs-server
    export TERM=xterm-24bits
    exec ${emacsclient} -t -s /run/user/1337/emacs1337/server $@
  '';

  ed = writeScriptBin "ed" ''
    #!${stdenv.shell}
    ${emacs-server}/bin/emacs-server
    exec ${emacsclient} -c -s /run/user/1337/emacs1337/server $@ 2>&1 >/dev/null
  '';

  fzf-fzf = writeScriptBin "fzf-fzf" ''
    #!${stdenv.shell}
    FZF_HEIGHT=''${FZF_HEIGHT:-100}
    FZF_MIN_HEIGHT=''${FZF_MIN_HEIGHT:-100}
    FZF_MARGIN=''${FZF_MARGIN:-5,5,5,5}
    FZF_PROMPT=''${FZF_PROMPT:- >}
    FZF_OPTS=''${FZF_OPTS:-"--reverse"}
    exec ${fzf}/bin/fzf --height=$FZF_HEIGHT \
        --min-height=$FZF_MIN_HEIGHT \
        --margin=$FZF_MARGIN \
        --prompt="$FZF_PROMPT" \
        --tac
        $FZF_OPTS⏎
  '';

  project-select = writeScriptBin "project-select" ''
    #!${stdenv.shell}
    projects=$@
    if [ -z "$projects" ]; then
      ${coreutils}/bin/echo "Please provide the project root directories to search as arguments"
      exit 1
    fi
    export FZF_PROMPT="goto project >"
    ${fd}/bin/fd -d 8 -pHI -t f '.*\.git/config$' $projects | \
      ${gnused}/bin/sed 's|/\.git/config||g' | \
      ${gnused}/bin/sed "s|$HOME/||g" | \
      ${fzf-fzf}/bin/fzf-fzf | \
      ${findutils}/bin/xargs -I{} ${coreutils}/bin/echo "$HOME/{}"
  '';

  screenshot = writeScriptBin "screenshot" ''
    #!${stdenv.shell}
    name=$(${coreutils}/bin/date +%Y-%m-%d_%H:%M:%S_screen)
    output_dir=$HOME/Pictures/screenshots
    fmt=png
    ${coreutils}/bin/mkdir -p $output_dir
    #killall compton
    ${maim}/bin/maim -s --format=$fmt $output_dir/$name.$fmt
  '';

  browse = writeScriptBin "browse" ''
    #!${stdenv.shell}
    exec ${browser}
  '';

  terminal = writeScriptBin "terminal" ''
    #!${stdenv.shell}
    if [ "$_TERMEMU" = "termite" ]; then
      CONFIG=$HOME/.config/termite/config$TERMINAL_CONFIG
      ${termite}/bin/termite --config $CONFIG $@
    else
      CONFIG=$HOME/.config/alacritty/alacritty$TERMINAL_CONFIG.yml
      ${alacritty}/bin/alacritty --config-file $CONFIG $@
    fi
  '';

  launch = writeScriptBin "launch" ''
    #!${stdenv.shell}
    cmd=$@
    if [ -z "$cmd" ]; then
      read cmd
    fi
    MSG=${sway}/bin/swaymsg
    if [ "$_SET_WS_NAME" = "y" ]; then
      name=$(${coreutils}/bin/echo $cmd | ${gawk}/bin/awk '{print $1}')
      if [ "$_USE_NAME" ]; then
          name=$_USE_NAME
      fi
      wsname=$($MSG -t get_workspaces | ${jq}/bin/jq -r '.[] | select(.focused==true).name')
      if ${coreutils}/bin/echo "$wsname" | ${gnugrep}/bin/grep -E '^[0-9]:? ?+$' > /dev/null; then
        $MSG "rename workspace to \"$wsname: $name\"" 2>&1 >/dev/null
      fi
    fi
    echo "${fire}/bin/fire $cmd" | ${stdenv.shell}
  '';

  rename-workspace = writeScriptBin "rename-workspace" ''
    #!${stdenv.shell}
    CMD=${sway}/bin/swaymsg
    WSNUM=$($CMD -t get_workspaces | ${jq}/bin/jq '.[] | select(.focused==true).name' | ${coreutils}/bin/cut -d"\"" -f2 | ${gnugrep}/bin/grep -o -E '[[:digit:]]+')
    if [ -z "$@" ]; then
        exit 0
    fi
    $CMD "rename workspace to \"$WSNUM: $@\"" 2>&1 >/dev/null
  '';

  fzf-run = writeScriptBin "fzf-run" ''
    #!${bashInteractive}/bin/bash
    export FZF_PROMPT="run >"
    export _SET_WS_NAME=y

    compgen -c | \
    fzf-fzf | \
    launch
  '';

  fzf-window = writeScriptBin "fzf-window" ''
    #!${stdenv.shell}
    cmd=$1
    shift
    export _TERMEMU=termite
    export TERMINAL_CONFIG=-large-font
    if ${ps}/bin/ps aux | grep '\-c fzf-window' | ${gnugrep}/bin/grep -v grep 2>&1 > /dev/null; then
        exit
    fi
    exec terminal -t "fzf-window" -e "$cmd $@"
  '';

  fzf-passmenu = writeScriptBin "fzf-passmenu" ''
    #!${stdenv.shell}
    export _TERMEMU=termite
    export FZF_PROMPT="search for password >"
    ## because of some stupid bug: https://github.com/jordansissel/xdotool/issues/49

    passfile=$1
    prefix=$(readlink -f $HOME/.password-store)
    if [ -z "$_passmenu_didsearch" ]; then
      export _passmenu_didsearch=y
      ${fd}/bin/fd --type f -E '/notes/' '.gpg$' $HOME/.password-store | \
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
      ${coreutils}/bin/echo -n $(${coreutils}/bin/basename "$1")
    }

    getpass() {
      ${coreutils}/bin/echo -n $(${gnupg}/bin/gpg --decrypt "$prefix/$1.gpg" 2>/dev/null | ${coreutils}/bin/head -1)
    }

    login=$(getlogin "$passfile")
    pass=$(getpass "$passfile")

    if [ "$pass" = "" ]; then
      ${libnotify}/bin/notify-send -i $error_icon -a "Password store" -u critical "Decrypt error" "Error decrypting password file, is your gpg card inserted?"
    else
      if [ -z "$SWAYSOCK"]; then
        if [ -z "$passonly" ]; then
          ${coreutils}/bin/echo -n $login | ${xdotool}/bin/xdotool type --clearmodifiers --file -
          ${xdotool}/bin/xdotool key Tab
        fi
        ${coreutils}/bin/echo -n $pass | ${xdotool}/bin/xdotool type --clearmodifiers --file -
        if [ -z "$nosubmit" ]; then
          ${xdotool}/bin/xdotool key Return
        fi
      else
          ${coreutils}/bin/echo -n "$pass" | ${wl-clipboard}/bin/wl-copy
      fi
    fi

  '';

  rofi-passmenu = writeScriptBin "rofi-passmenu" ''
    #!${stdenv.shell}
    PROMPT=" for password >"

    prefix=$(readlink -f $HOME/.password-store)
    passfile=$(${fd}/bin/fd --type f -E '/notes/' '.gpg$' $HOME/.password-store | \
       ${gnused}/bin/sed "s|$prefix/||g" | ${gnused}/bin/sed 's|.gpg$||g' | \
       ${rofi}/bin/rofi -dmenu -p "$PROMPT")

    if [ "$passfile" = "" ]; then
      exit
    fi

    error_icon=~/Pictures/icons/essential/error.svg

    getlogin() {
      ${coreutils}/bin/echo -n $(${coreutils}/bin/basename "$1")
    }

    getpass() {
      ${coreutils}/bin/echo -n $(${gnupg}/bin/gpg --decrypt "$prefix/$1.gpg" 2>/dev/null | ${coreutils}/bin/head -1)
    }

    login=$(getlogin "$passfile")
    pass=$(getpass "$passfile")

    if [ "$pass" = "" ]; then
      ${libnotify}/bin/notify-send -i $error_icon -a "Password store" -u critical "Decrypt error" "Error decrypting password file, is your gpg card inserted?"
    else
      if [ -z "$SWAYSOCK"]; then
        if [ -z "$passonly" ]; then
          ${coreutils}/bin/echo -n $login | ${xdotool}/bin/xdotool type --clearmodifiers --file -
          ${xdotool}/bin/xdotool key Tab
        fi
        ${coreutils}/bin/echo -n $pass | ${xdotool}/bin/xdotool type --clearmodifiers --file -
        if [ -z "$nosubmit" ]; then
          ${xdotool}/bin/xdotool key Return
        fi
      else
          ${coreutils}/bin/echo -n "$pass" | ${wl-clipboard}/bin/wl-copy
      fi
    fi
  '';

  autorandr-postswitch = writeScriptBin "autorandr-postswitch" ''
    #!${stdenv.shell}
    BG=$(${coreutils}/bin/cat /etc/nixos/meta.nix | ${gnugrep}/bin/grep dmBackground | ${gawk}/bin/awk '{print $3}' | ${gnused}/bin/sed 's|[";]||g')
    ${killall}/bin/killall compton
    ${coreutils}/bin/echo "Setting background: '$BG'"
    if [ -e "$BG" ]; then
       ${feh}/bin/feh --bg-fill $BG
    fi

  '';

  start-sway = writeScriptBin "start-sway" ''
    #!${stdenv.shell}

    export XDG_SESSION_TYPE=wayland
    export XKB_DEFAULT_LAYOUT=se
    export XKB_DEFAULT_VARIANT=mac
    export XKB_DEFAULT_MODEL=pc105
    export XKB_DEFAULT_OPTIONS=ctrl:nocaps,lv3:lalt_switch,compose:ralt,lv3:ralt_alt

    export GTK_THEME="${settings.dconf."org/gnome/desktop/interface".gtk-theme}"
    export QT_STYLE_OVERRIDE=gtk
    export VISUAL=ed
    export EDITOR=$VISUAL
    export PROJECTS=~/Development
    if [ -e .config/syncthing/config.xml ]; then
       SYNCTHING_API_KEY=$(cat .config/syncthing/config.xml | grep apikey | awk -F">|</" '{print $2}')
       if [ "$SYNCTHING_API_KEY" != "" ]; then
          export SYNCTHING_API_KEY
       fi
    fi

    exec dbus-launch --exit-with-session sway
  '';

  ## so clearly expects such a named entry in ~.ssh/config
  kctl = writeScriptBin "kctl" ''
     #!${stdenv.shell}

     TUNNEL=kubetunnel

     if [ "$1" = "stop-tunnel" ]; then
       if ${openssh}/bin/ssh -O check $TUNNEL 2>&1 > /dev/null; then
         ${openssh}/bin/ssh -O exit $TUNNEL
       fi
       exit
     fi

     if ! ${openssh}/bin/ssh -qf -N $TUNNEL 2>&1 > /dev/null; then
       echo "ERROR: couldn't start $TUNNEL" >&2
       exit 1
     fi

     ${kubectl}/bin/kubectl --server=https://127.0.0.1:6443 --insecure-skip-tls-verify=true $@
  '';

in

  {
    paths = {
      edit = edit;
      edi = edi;
      ed = ed;
      emacs-server = emacs-server;
      fzf-fzf = fzf-fzf;
      project-select = project-select;
      terminal = terminal;
      launch = launch;
      fzf-passmenu = fzf-passmenu;
      rofi-passmenu = rofi-passmenu;
      fzf-run = fzf-run;
      fzf-window = fzf-window;
      browse = browse;
      rename-workspace = rename-workspace;
      screenshot = screenshot;
      autorandr-postswitch = autorandr-postswitch;
      kctl = kctl;
      start-sway = start-sway;
    };
  }
