{
  stdenv,
  lib,
  libdot,
  writeText,
  settings,
  ...
}:

let
  config = settings.i3status-rust;
  theme = settings.theme;
  i3statusconf = writeText "i3status-rust.conf" ''
     [theme]
     name = "modern"
     [theme.overrides]
     idle_bg = "${theme.base03}DD"
     idle_fg = "${theme.base05}"
     info_bg = "${theme.base08}DD"
     info_fg = "${theme.base00}"
     good_bg = "${theme.base0A}DD"
     good_fg = "${theme.base00}"
     warning_bg = "${theme.base0D}DD"
     warning_fg = "${theme.base00}"
     critical_bg = "${theme.base0B}DD"
     critical_fg = "${theme.base00}"

     [icons]
     name = "awesome"
     [icons.overrides]
     cpu = "  "

     [[block]]
     block = "cpu"
     interval = 1

     [[block]]
     block = "battery"
     interval = 10
     format = "{percentage}% {time}"

     [[block]]
     block = "net"
     device = "wlan0"
     ssid = true
     signal_strength = true
     ip = false
     speed_up = true
     graph_up = false
     interval = 5

     [[block]]
     block = "music"
     buttons = ["play", "prev" ,"next"]

     [[block]]
     block = "sound"

     [[block]]
     block = "time"
     interval = 1
     format = "%b-%d %H:%M:%S"
  '';

in

  i3statusconf