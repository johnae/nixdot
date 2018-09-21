{
  stdenv,
  libdot,
  writeText,
  ...
}:

let
  config = writeText "termite-config" ''
    # Copyright (c) 2016-present Arctic Ice Studio <development@arcticicestudio.com>
    # Copyright (c) 2016-present Sven Greb <code@svengreb.de>

    # Project:    Nord Termite
    # Repository: https://github.com/arcticicestudio/nord-termite
    # License:    MIT

    [colors]
    cursor = #d8dee9
    cursor_foreground = #2e3440

    foreground = #d8dee9
    foreground_bold = #d8dee9
    # background = #2e3440
    background = #002b36

    highlight = #4c566a

    color0  = #3b4252
    color1  = #bf616a
    color2  = #a3be8c
    color3  = #ebcb8b
    color4  = #81a1c1
    color5  = #b48ead
    color6  = #88c0d0
    color7  = #e5e9f0
    color8  = #4c566a
    color9  = #bf616a
    color10 = #a3be8c
    color11 = #ebcb8b
    color12 = #81a1c1
    color13 = #b48ead
    color14 = #8fbcbb
    color15 = #eceff4

    [options]
    font = Source Code Pro 14
  '';

  configLargeFont = writeText "termite-large-font-config" ''
    # Solarized dark color scheme

    [colors]
    # Base16 Solarized Dark
    # Author: Ethan Schoonover (modified by aramisgithub)

    foreground          = #93a1a1
    foreground_bold     = #eee8d5
    cursor              = #eee8d5
    cursor_foreground   = #002b36
    background          = rgba(0, 43, 54, 0.96)

    # 16 color space

    # Black, Gray, Silver, White
    color0  = #002b36
    color8  = #657b83
    color7  = #93a1a1
    color15 = #fdf6e3

    # Red
    color1  = #dc322f
    color9  = #dc322f

    # Green
    color2  = #859900
    color10 = #859900

    # Yellow
    color3  = #b58900
    color11 = #b58900

    # Blue
    color4  = #268bd2
    color12 = #268bd2

    # Purple
    color5  = #6c71c4
    color13 = #6c71c4

    # Teal
    color6  = #2aa198
    color14 = #2aa198

    # Extra colors
    color16 = #cb4b16
    color17 = #d33682
    color18 = #073642
    color19 = #586e75
    color20 = #839496
    color21 = #eee8d5

    [options]
    font = Source Code Pro 28
  '';

in

  {
    __toString = self: ''
      ${libdot.mkdir { path = ".config/termite"; }}
      ${libdot.copy { path = config; to = ".config/termite/config";  }}
      ${libdot.copy { path = configLargeFont; to = ".config/termite/config-large-font";  }}
    '';
  }
