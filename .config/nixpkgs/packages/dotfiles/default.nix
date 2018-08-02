{stdenv, lib, pkgs, ...}:

let
  settings = import (builtins.getEnv "HOME");

  scriptsPkg = pkgs.callPackage ./scripts { browser = "${pkgs.latest.firefox-beta-bin}/bin/firefox"; };

  scripts = [
    scriptsPkg
  ];


  i3dot = pkgs.callPackage ./i3 { launch = scriptsPkg.paths.launch;
                                  terminal = scriptsPkg.paths.terminal;
                                  fzf-window = scriptsPkg.paths.fzf-window;
                                  fzf-run = scriptsPkg.paths.fzf-run;
                                  fzf-passmenu = scriptsPkg.paths.fzf-passmenu;
                                  rename-workspace = scriptsPkg.paths.rename-workspace;
                                  screenshot = scriptsPkg.paths.screenshot;
                                  my-emacs = pkgs.my-emacs; };

   gnupgDot = pkgs.callPackage ./gnupg { };
   fishDot = pkgs.callPackage ./fish { };
   alacrittyDot = pkgs.callPackage ./alacritty { };
   sshDot = pkgs.callPackage ./ssh { settings = settings; };
   gitDot = pkgs.callPackage ./git { settings = settings; my-emacs = pkgs.my-emacs; };
   pulseDot = pkgs.callPackage ./pulse { };
   gsimplecalDot = pkgs.callPackage ./gsimplecal { };
   mimeappsDot = pkgs.callPackage ./mimeapps { };
   yubicoDot = pkgs.callPackage ./yubico { };
   direnvDot = pkgs.callPackage ./direnv { };
   xresourcesDot = pkgs.callPackage ./xresources { };

  dotfiles = [ i3dot gnupgDot
               fishDot alacrittyDot
               sshDot gitDot
               pulseDot gsimplecalDot
               mimeappsDot yubicoDot
               direnvDot xresourcesDot
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
    chmod u+rwx $root
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
      cmd="cp --no-preserve=ownership -R $file $root/"
      echo $cmd
      $cmd
    done
    find ${home}/.nix-profile/dotfiles/ -type f | sed  "s|${home}/.nix-profile/dotfiles/||g" > $root/.dotfiles_manifest
    echo $latestVersion > $root/.dotfiles_version
    ${pkgs.i3}/bin/i3-msg restart
  '';

  install = xs: fun: lib.concatStringsSep "\n" (lib.concatMap (x: (lib.mapAttrsToList fun x.paths)) xs);

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
    ${install dotfiles (name: value: ''
                                       echo "installing ${name} in $(pwd)/${name}"
                                       install -dm 755 $(dirname ${name})
                                       cat ${value} > ${name}
                                     ''
    )}

    popd
    ${install scripts (name: value: ''
                                       echo "installing script ${name} to $bin"
                                       cp -r ${value}/bin/${name} $bin/
                                    ''
    )}
    cp ${home-update}/bin/home-update $bin/home-update
  '';
}