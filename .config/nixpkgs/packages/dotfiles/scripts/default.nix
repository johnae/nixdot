{
 stdenv,
 writeScriptBin,
 my-emacs,
 i3, ps, jq, fire,
 fd, fzf, bashInteractive,
 gnupg, gawk, gnused,
 gnugrep, findutils, coreutils,
 alacritty, libnotify, xdotool,
 maim, slop, feh, killall,
 browser,
 ...}:

let
  emacsclient = "${my-emacs}/bin/emacsclient";

  edit = writeScriptBin "edit" ''
    #!${stdenv.shell}
    exec ${emacsclient} -n -a "" -c $@ 2>&1 >/dev/null
  '';

  edi = writeScriptBin "edi" ''
    #!${stdenv.shell}
    export TERM=xterm-24bits
    exec ${emacsclient} -a "" -t $@
  '';

  ed = writeScriptBin "ed" ''
    #!${stdenv.shell}
    exec ${emacsclient} -a "" -c $@ 2>&1 >/dev/null
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
    mkdir -p $output_dir
    #killall compton
    ${maim}/bin/maim -s --format=$fmt $output_dir/$name.$fmt
    #~/.i3/compton
  '';

  browse = writeScriptBin "browse" ''
    #!${stdenv.shell}
    exec ${browser}
  '';

  ## This is what i3 refers to and it could/should be extended
  ## with different color options and sizes later
  terminal = writeScriptBin "terminal" ''
    #!${stdenv.shell}
    CONFIG=$HOME/.config/alacritty/alacritty$TERMINAL_CONFIG.yml
    ${alacritty}/bin/alacritty --config-file $CONFIG $@
  '';

  launch = writeScriptBin "launch" ''
    #!${stdenv.shell}
    cmd=$@
    if [ -z "$cmd" ]; then
      read cmd
    fi
    if [ "$_SET_WS_NAME" = "y" ]; then
      name=$(${coreutils}/bin/echo $cmd | ${gawk}/bin/awk '{print $1}')
      if [ "$_USE_NAME" ]; then
          name=$_USE_NAME
      fi
      wsname=$(${i3}/bin/i3-msg -t get_workspaces | ${jq}/bin/jq -r '.[] | select(.focused==true).name')
      if ${coreutils}/bin/echo "$wsname" | ${gnugrep}/bin/grep -E '^[0-9]+$' > /dev/null; then
        ${i3}/bin/i3-msg "rename workspace to \"$wsname: $name\"" 2>&1 >/dev/null
      fi
    fi
    echo "${fire}/bin/fire $cmd" | ${stdenv.shell}
  '';

  rename-workspace = writeScriptBin "rename-workspace" ''
    #!${stdenv.shell}
    WSNUM=$(${i3}/bin/i3-msg -t get_workspaces | ${jq}/bin/jq '.[] | select(.focused==true).name' | ${coreutils}/bin/cut -d"\"" -f2 | ${gnugrep}/bin/grep -o -E '[[:digit:]]+')
    if [ -z "$@" ]; then
        exit 0
    fi
    ${i3}/bin/i3-msg "rename workspace to \"$WSNUM: $@\"" 2>&1 >/dev/null
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
    export TERMINAL_CONFIG=-large-font
    if ${ps}/bin/ps aux | grep '\-c fzf-window' | ${gnugrep}/bin/grep -v grep 2>&1 > /dev/null; then
        exit
    fi
    exec terminal -t "fzf-window" -e ${stdenv.shell} -c "$cmd $@"
  '';

  fzf-passmenu = writeScriptBin "fzf-passmenu" ''
    #!${stdenv.shell}
    export FZF_PROMPT="search for password >"

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
      if [ -z "$passonly" ]; then
        ${coreutils}/bin/echo -n $login | ${xdotool}/bin/xdotool type --clearmodifiers --file -
        ${xdotool}/bin/xdotool key Tab
      fi
      ${coreutils}/bin/echo -n $pass | ${xdotool}/bin/xdotool type --clearmodifiers --file -
      if [ -z "$nosubmit" ]; then
        ${xdotool}/bin/xdotool key Return
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

in

  {
    paths = {
      edit = edit;
      edi = edi;
      ed = ed;
      fzf-fzf = fzf-fzf;
      project-select = project-select;
      terminal = terminal;
      launch = launch;
      fzf-passmenu = fzf-passmenu;
      fzf-run = fzf-run;
      fzf-window = fzf-window;
      browse = browse;
      rename-workspace = rename-workspace;
      screenshot = screenshot;
      autorandr-postswitch = autorandr-postswitch;
    };
  }