{stdenv, lib, pkgs, ...}:

{
  sway = rec {
    sway-outputs = {
      eDP-1 = "scale 2.0 pos 0 0 res 3200x1800";
    };
  };
}
