{stdenv, lib, pkgs, ...}:

with lib;

let


  libdot = pkgs.callPackage ./libdot.nix { };
  toShell = libdot.mapAttrsToMultilineString;

  settings = import (builtins.getEnv "HOME") { inherit lib; };

  # scripts = (pkgs.callPackage ./scripts { browser = "${pkgs.latest.firefox-beta-bin}/bin/firefox"; inherit settings; }).paths;
  scripts = (pkgs.callPackage ./scripts { browser = "${pkgs.epiphany}/bin/epiphany"; inherit settings; }).paths;

  swaydot = with scripts; pkgs.callPackage ./sway {
        inherit libdot browse launch edi edit emacs-server terminal fzf-window fzf-run fzf-passmenu rofi-passmenu rename-workspace screenshot settings;
  };

  termiteDot = pkgs.callPackage ./termite { inherit libdot settings; };
  gnupgDot = pkgs.callPackage ./gnupg { inherit libdot settings; };
  fishDot = pkgs.callPackage ./fish { inherit libdot settings; };
  alacrittyDot = pkgs.callPackage ./alacritty { inherit libdot settings; };
  sshDot = pkgs.callPackage ./ssh { inherit libdot settings; };
  gitDot = pkgs.callPackage ./git { inherit libdot settings; };
  pulseDot = pkgs.callPackage ./pulse { inherit libdot settings; };
  gsimplecalDot = pkgs.callPackage ./gsimplecal { inherit libdot settings; };
  mimeappsDot = pkgs.callPackage ./mimeapps { inherit libdot settings; };
  yubicoDot = pkgs.callPackage ./yubico { inherit libdot settings; };
  direnvDot = pkgs.callPackage ./direnv { inherit libdot settings; };
  xresourcesDot = pkgs.callPackage ./xresources { inherit libdot settings; };
  tmuxDot = pkgs.callPackage ./tmux { inherit libdot settings; };

  dotfiles = [ gnupgDot fishDot swaydot
               alacrittyDot sshDot gitDot
               pulseDot gsimplecalDot tmuxDot
               mimeappsDot yubicoDot termiteDot
               direnvDot xresourcesDot
             ];

  home = builtins.getEnv "HOME";

  home-update = with libdot; with pkgs; pkgs.writeShellScriptBin "home-update" ''
    #!${stdenv.shell}
    set -e
    export PATH=${makeSearchPath "bin" [ coreutils findutils nix sway gnused ]}:$PATH
    root=''${1:-${home}}
    latestVersion=$(nix-store --query --hash $(readlink ${home}/.nix-profile/dotfiles))
    currentVersion=""
    if [ -e $root/.dotfiles_version ]; then
      currentVersion=$(cat $root/.dotfiles_version)
    fi
    if [ "$currentVersion" = "$latestVersion" ]; then
      echo "Up-to-date already"
      exit 0
    else
      echo "Updating to latest version '$latestVersion' from '$currentVersion'"
    fi
    shopt -s dotglob
    mkdir -p $root
    chmod u+rwx $root
    if [ -e $root/.dotfiles_manifest ]; then
      for file in $(cat $root/.dotfiles_manifest); do
        if [ ! -e ${home}/.nix-profile/dotfiles/$file ]; then
          echo "removing deleted dotfile '$file'"
          rm -f $root/$file
        fi
      done
      rm -f $root/.dotfiles_manifest
    fi
    for file in ${home}/.nix-profile/dotfiles/*; do
      if [ "$(basename $file)" = "set-permissions.sh" ]; then
         continue
      fi
      cmd="cp --no-preserve=ownership,mode -rf $file $root/"
      echo $cmd
      $cmd
    done
    if [ -e ${home}/.nix-profile/dconf/dconf.conf ]; then
      echo "Updating dconf..."
      cat ${home}/.nix-profile/dconf/dconf.conf | ${pkgs.gnome3.dconf}/bin/dconf load /
    else
      echo "No dconf found, skipping"
    fi
    if [ -d ${home}/.nix-profile/terminfo ]; then
      echo "Updating terminfo database..."
      rm -rf ${home}/.terminfo
      for file in ${home}/.nix-profile/terminfo/*; do
        ${pkgs.ncurses}/bin/tic -x -o ~/.terminfo $file
      done
    fi
    echo Ensuring permissions on dotfiles...
    pushd $root
    ${stdenv.shell} -x ${home}/.nix-profile/dotfiles/set-permissions.sh
    popd
    find ${home}/.nix-profile/dotfiles/ -type f | grep -v "set-permissions.sh" | sed  "s|${home}/.nix-profile/dotfiles/||g" > $root/.dotfiles_manifest
    echo $latestVersion > $root/.dotfiles_version
    swaymsg reload || true
    ${pkgs.killall}/bin/killall -s HUP $(${pkgs.coreutils}/bin/basename $SHELL)
  '';

in

stdenv.mkDerivation rec {
  name = "dotfiles";
  phases = [ "installPhase" ];
  src = ./.;
  installPhase = with pkgs; with libdot; ''
    export PATH=${makeSearchPath "bin" [ coreutils findutils nix sway gnused ]}:$PATH
    dotfiles=$out/dotfiles
    dconf=$out/dconf
    terminfo=$out/terminfo
    bin=$out/bin
    install -dm 755 $dotfiles
    install -dm 755 $dconf
    install -dm 755 $terminfo
    install -dm 755 $bin

    pushd $dotfiles
    ${concatStringsSep "\n" dotfiles}
    popd

    ${toShell settings.dconf (name: value:
    ''
      echo "[${name}]" >> $dconf/dconf.conf
      ${if isAttrs value then
          toShell value (name: value:
          ''
            echo "${name}='${value}'" >> $dconf/dconf.conf
          ''
          )
        else
          value
      }
    ''
    )}

    ${toShell settings.terminfo (name: value:
    ''
      echo "${value}" >> $terminfo/${name}.terminfo
    ''
    )}

    ${toShell scripts (name: value:
    ''
      echo "installing script ${name} to $bin"
      cp -r ${value}/bin/${name} $bin/
    ''
    )}

    cp ${home-update}/bin/home-update $bin/home-update
  '';
}
