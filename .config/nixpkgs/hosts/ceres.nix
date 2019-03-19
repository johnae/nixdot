{stdenv, lib, pkgs, ...}:

let

  mouse = {
    dwt = true;
    natural_scroll = true;
  };

  touchpad = {
    dwt = true;
    tap = true;
    natural_scroll = true;
  };

in

{
  sway = {
    sway-outputs = {
      eDP-1 = "scale 2.0 pos 0 0 res 3840x2160";
      "\"Unknown ASUS PB27U 0x0000C167\"" = "scale 1.6";
    };
    sway-inputs = {
      "1739:30383:DELL07E6:00_06CB:76AF_Touchpad" = touchpad;
      "1118:2354:Surface_Arc_Mouse_Keyboard" = mouse;
    };
  };
}
