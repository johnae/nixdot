{stdenv, lib, pkgs, ...}:

{
  sway = {
    sway-inputs = {
      "2:14:ETPS/2_Elantech_Touchpad" = {
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