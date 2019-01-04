{stdenv, lib, pkgs, ...}:

{
  sway = rec {
    sway-outputs = {
      eDP-1 = "scale 2.0 pos 0 0 res 3200x1800";
    };
    sway-inputs = {
      "1739:30383:DLL075B:01_06CB:76AF_Touchpad" = {
        dwt = true;
        tap = true;
        natural_scroll = true;
      };
      "1118:2354:Surface_Arc_Mouse_Keyboard" = {
        dwt = true;
        natural_scroll = true;
      };
    };
  };
}
