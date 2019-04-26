self: super: rec {
  wl-clipboard-x11 = super.callPackage ../packages/wl-clipboard-x11 { };
  #alacritty = super.alacritty.override { xclip = wl-clipboard-x11; };
  alacritty = super.callPackage ../packages/alacritty { xclip = wl-clipboard-x11; };
}
