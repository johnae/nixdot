{stdenv, libdot, writeText, ...}:

let

  config = writeText "Xresources" ''
    ! Fonts {{{
    Xft.lcdfilter: lcddefault
    Xft.autohint: 0
    Xft.antialias: 1
    Xft.hinting:   1
    Xft.rgba:      rgb
    Xft.hintstyle: hintslight
    Xft.dpi: 96
    ! }}}

    ## rofi config
    rofi.color-enabled: true
    rofi.color-normal: #004b46,#fdf6e3,#004b46,#004b46,#9999FF
    rofi.color-window: #004b46
    rofi.separator-style: none
    rofi.lines: 3
    rofi.bw: 0
    rofi.hide-scrollbar: true
    rofi.eh: 2
    rofi.padding: 300
    rofi.fullscreen: true
    rofi.opacity: 85
    rofi.matching: fuzzy
    rofi.font: Roboto 18
  '';

in

  {
    __toString = self: ''
      ${libdot.copy { path = config; to = ".Xresources"; }}
    '';
  }