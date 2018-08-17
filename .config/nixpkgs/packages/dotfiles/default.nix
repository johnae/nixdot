{stdenv, lib, pkgs, ...}:


let
  libdot = pkgs.callPackage ./libdot.nix { };
  settings = import (builtins.getEnv "HOME");

  scriptsPkg = pkgs.callPackage ./scripts { browser = "${pkgs.latest.firefox-beta-bin}/bin/firefox"; };

  scripts = [
    scriptsPkg
  ];

   i3dot = with scriptsPkg.paths; pkgs.callPackage ./i3 {
         inherit libdot launch terminal fzf-window fzf-run fzf-passmenu rename-workspace screenshot;
   };

   gnupgDot = pkgs.callPackage ./gnupg { inherit libdot; };
   fishDot = pkgs.callPackage ./fish { inherit libdot; };
   alacrittyDot = pkgs.callPackage ./alacritty { inherit libdot; };
   sshDot = pkgs.callPackage ./ssh { inherit settings libdot; };
   gitDot = pkgs.callPackage ./git { inherit settings libdot; };
   pulseDot = pkgs.callPackage ./pulse { inherit libdot; };
   gsimplecalDot = pkgs.callPackage ./gsimplecal { inherit libdot; };
   mimeappsDot = pkgs.callPackage ./mimeapps { inherit libdot; };
   yubicoDot = pkgs.callPackage ./yubico { inherit libdot; };
   direnvDot = pkgs.callPackage ./direnv { inherit libdot; };
   xresourcesDot = pkgs.callPackage ./xresources { inherit libdot; };

   dotfiles = [ i3dot gnupgDot fishDot
                alacrittyDot sshDot gitDot
                pulseDot gsimplecalDot
                mimeappsDot yubicoDot
                direnvDot xresourcesDot
              ];

  home = builtins.getEnv "HOME";

  home-update = pkgs.writeScriptBin "home-update" ''
    #!${stdenv.shell}
    root=''${1:-${home}}
    latestVersion=$(${pkgs.nix}/bin/nix-store --query --hash $(${pkgs.coreutils}/bin/readlink ${home}/.nix-profile/dotfiles))
    currentVersion=""
    if [ -e $root/.dotfiles_version ]; then
      currentVersion=$(${pkgs.coreutils}/bin/cat $root/.dotfiles_version)
    fi
    if [ "$currentVersion" = "$latestVersion" ]; then
      ${pkgs.coreutils}/bin/echo "Up-to-date already"
      exit 0
    else
      ${pkgs.coreutils}/bin/echo "Updating to latest version '$latestVersion' from '$currentVersion'"
    fi
    shopt -s dotglob
    ${pkgs.coreutils}/bin/mkdir -p $root
    ${pkgs.coreutils}/bin/chmod u+rwx $root
    if [ -e $root/.dotfiles_manifest ]; then
      for file in $(${pkgs.coreutils}/bin/cat $root/.dotfiles_manifest); do
        if [ ! -e ${home}/.nix-profile/dotfiles/$file ]; then
          ${pkgs.coreutils}/bin/echo "removing deleted dotfile '$file'"
          ${pkgs.coreutils}/bin/rm $root/$file
        fi
      done
      ${pkgs.coreutils}/bin/rm $root/.dotfiles_manifest
    fi
    for file in ${home}/.nix-profile/dotfiles/*; do
      if [ "$(${pkgs.coreutils}/bin/basename $file)" = "set-permissions.sh" ]; then
         continue
      fi
      cmd="${pkgs.coreutils}/bin/cp --no-preserve=ownership,mode -rf $file $root/"
      ${pkgs.coreutils}/bin/echo $cmd
      $cmd
    done
    ${pkgs.coreutils}/bin/echo Ensuring permissions on dotfiles...
    ${stdenv.shell} -x ${home}/.nix-profile/dotfiles/set-permissions.sh
    ${pkgs.findutils}/bin/find ${home}/.nix-profile/dotfiles/ -type f | ${pkgs.gnused}/bin/sed  "s|${home}/.nix-profile/dotfiles/||g" > $root/.dotfiles_manifest
    ${pkgs.coreutils}/bin/echo $latestVersion > $root/.dotfiles_version
    ${pkgs.i3}/bin/i3-msg restart
    ${pkgs.coreutils}/bin/true
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
    ${lib.concatStringsSep "\n" dotfiles}
    popd
    ${libdot.install scripts (name: value: ''
                                       echo "installing script ${name} to $bin"
                                       cp -r ${value}/bin/${name} $bin/
                                    ''
    )}
    cp ${home-update}/bin/home-update $bin/home-update
  '';
}
