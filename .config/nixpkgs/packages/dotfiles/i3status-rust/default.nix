{
  stdenv,
  lib,
  libdot,
  writeText,
  curl,
  jq,
  settings,
  ...
}:

let
  config = settings.i3status-rust;
  theme = settings.theme;
  check-nixos-version = libdot.writeStrictShellScriptBin "check-nixos-version" ''
    CURRENT=$(${curl}/bin/curl -sS https://howoldis.herokuapp.com/api/channels | \
              ${jq}/bin/jq -r '.[] | select(.name == "nixos-unstable") | "\(.commit) (\(.humantime) ago)"')
    LATEST=$(echo "$CURRENT" | awk '{print $1}')
    LOCAL=$(awk -F'.' '{print $2}' < ~/.nix-defexpr/channels_root/nixos/.version-suffix)
    if [ "$LOCAL" != "$LATEST" ]; then
      echo " $CURRENT"
    else
      echo " $CURRENT"
    fi
  '';
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
     block = "custom"
     command = "${check-nixos-version}/bin/check-nixos-version"
     interval = 600

     [[block]]
     block = "cpu"
     interval = 1

     [[block]]
     block = "backlight"

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

     ## headphones
     [[block]]
     block = "bluetooth"
     mac = "04:52:C7:5F:CC:B6"

     ## mouse
     [[block]]
     block = "bluetooth"
     mac = "D5:17:1A:80:22:AA"

     ## keyboard at home
     [[block]]
     block = "bluetooth"
     mac = "CA:2A:50:27:92:C6"

     ## keyboard at work
     [[block]]
     block = "bluetooth"
     mac = "F3:BD:17:19:97:05"

     [[block]]
     block = "time"
     interval = 1
     format = "%b-%d %H:%M:%S"
  '';

in

  i3statusconf