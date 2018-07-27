{stdenv, lib, pkgs, ...}:

let
  settings = import (builtins.getEnv "HOME");

  scriptsPkg = pkgs.callPackage ./scripts { browser = "${pkgs.latest.firefox-beta-bin}/bin/firefox"; };

  scripts = [
    scriptsPkg
  ];

  dotfiles = [
    (pkgs.callPackage ./i3 { launch = scriptsPkg.paths.launch;
                                        terminal = scriptsPkg.paths.terminal;
                                        fzf-window = scriptsPkg.paths.fzf-window;
                                        fzf-run = scriptsPkg.paths.fzf-run;
                                        fzf-passmenu = scriptsPkg.paths.fzf-passmenu;
                                        rename-workspace = scriptsPkg.paths.rename-workspace;
                                        my-emacs = pkgs.my-emacs; })
    (pkgs.callPackage ./gnupg { })
    (pkgs.callPackage ./fish { })
    (pkgs.callPackage ./alacritty { })
    (pkgs.callPackage ./ssh { settings = settings; })
    (pkgs.callPackage ./git { settings = settings; my-emacs = pkgs.my-emacs; })
    (pkgs.callPackage ./pulse { })
    (pkgs.callPackage ./gsimplecal { })
    (pkgs.callPackage ./mimeapps { })
    (pkgs.callPackage ./yubico { })
  ];

  home = builtins.getEnv "HOME";

  home-update = pkgs.writeScriptBin "home-update" ''
    #!${stdenv.shell}
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
    chmod ug+rwx $root
    if [ -e $root/.dotfiles_manifest ]; then
      for file in $(cat $root/.dotfiles_manifest); do
        if [ ! -e ${home}/.nix-profile/dotfiles/$file ]; then
          echo "removing deleted dotfile '$file'"
          rm $root/$file
        fi
      done
      rm $root/.dotfiles_manifest
    fi
    for file in ${home}/.nix-profile/dotfiles/*; do
      cmd="cp --no-preserve=ownership,mode -R $file $root/"
      echo $cmd
      $cmd
    done
    find ${home}/.nix-profile/dotfiles/ -type f | sed  "s|${home}/.nix-profile/dotfiles/||g" > $root/.dotfiles_manifest
    echo $latestVersion > $root/.dotfiles_version
  '';

in

stdenv.mkDerivation rec {
  name = "dotfiles";
  phases = [ "installPhase" ];
  src = ./.;
  installPhase = ''
    dotfiles=$out/dotfiles
    bin=$out/bin
    install -dm 755 $dotfiles
    install -dm 755 $bin
    pushd $dotfiles
    ${lib.concatStringsSep "\n" (
         lib.concatMap (
            x: (
               lib.mapAttrsToList (name: value: ''
                                                 echo "installing ${name} in $(pwd)/${name}"
                                                 install -dm 755 $(dirname ${name})
                                                 cat ${value} > ${name}
                                                '') x.paths
                      )
         ) dotfiles
     )}

    popd
    ${lib.concatStringsSep "\n" (
          lib.concatMap (
             x: (
               lib.mapAttrsToList (name: value: ''
                                                 echo "installing script ${name} to $bin"
                                                 cp -r ${value}/bin/${name} $bin/
                                                 '') x.paths)) scripts
                                                 )}
    cp ${home-update}/bin/home-update $bin/home-update
  '';
}