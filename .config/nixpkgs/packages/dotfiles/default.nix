{stdenv, lib, pkgs, ...}:

with lib;

let
  libdot = pkgs.callPackage ./libdot.nix { };
  settings = import (builtins.getEnv "HOME") { inherit lib; };

  scriptsPkg = pkgs.callPackage ./scripts { browser = "${pkgs.latest.firefox-beta-bin}/bin/firefox"; inherit settings; };

  scripts = [
    scriptsPkg
  ];

   i3dot = with scriptsPkg.paths; pkgs.callPackage ./i3 {
         inherit libdot launch terminal fzf-window fzf-run fzf-passmenu rename-workspace screenshot settings;
   };

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

   dotfiles = [ i3dot gnupgDot fishDot
                alacrittyDot sshDot gitDot
                pulseDot gsimplecalDot
                mimeappsDot yubicoDot
                direnvDot xresourcesDot
              ];

  home = builtins.getEnv "HOME";

  home-update = with libdot; with pkgs; pkgs.writeScriptBin "home-update" ''
    #!${stdenv.shell}
    set -e
    export PATH=${makeSearchPath "bin" [ coreutils findutils nix i3 gnused ]}:$PATH
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
    echo Ensuring permissions on dotfiles...
    pushd $root
    ${stdenv.shell} -x ${home}/.nix-profile/dotfiles/set-permissions.sh
    popd
    find ${home}/.nix-profile/dotfiles/ -type f | grep -v "set-permissions.sh" | sed  "s|${home}/.nix-profile/dotfiles/||g" > $root/.dotfiles_manifest
    echo $latestVersion > $root/.dotfiles_version
    i3-msg restart || true
  '';

in

stdenv.mkDerivation rec {
  name = "dotfiles";
  phases = [ "installPhase" ];
  src = ./.;
  installPhase = with pkgs; with libdot; ''
    export PATH=${makeSearchPath "bin" [ coreutils findutils nix i3 gnused ]}:$PATH
    dotfiles=$out/dotfiles
    bin=$out/bin
    install -dm 755 $dotfiles
    install -dm 755 $bin
    pushd $dotfiles
    ${concatStringsSep "\n" dotfiles}
    popd
    ${install scripts (name: value: ''
                                       echo "installing script ${name} to $bin"
                                       cp -r ${value}/bin/${name} $bin/
                                    ''
    )}
    cp ${home-update}/bin/home-update $bin/home-update
  '';
}
