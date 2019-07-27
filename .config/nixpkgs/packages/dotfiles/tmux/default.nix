{stdenv, libdot, writeText, fetchFromGitHub, ...}:

let

  nordTheme = fetchFromGitHub {
    owner = "arcticicestudio";
    repo = "nord-tmux";
    rev = "0f3d20ff54548cea1ce96893a9a3757d48e851ef";
    sha256 = "0j1ks9kiiby7cpik24dqx1mi5nccad0gj5gfwb5fd7hjfr46ml81";
  };

  config = writeText "tmux.conf" ''
    ## 24-bit please
    set-option -g default-terminal "xterm-256color"
    set-option -ga terminal-overrides ",*256col*:Tc"

    set-option -sg escape-time 20
    set-option -g prefix C-a
    set-option -g mode-keys vi
    set-option -g mouse on
    set-option -g set-clipboard on

    unbind C-a
    bind C-a send-prefix

    bind Escape copy-mode
    bind -T copy-mode-vi Escape send -X cancel
    bind -T copy-mode-vi v send -X begin-selection
    bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

    run-shell ${nordTheme}/nord.tmux
  '';

in

  {
    __toString = self: ''
      ${libdot.copy { path = config; to = ".tmux.conf";  }}
    '';
  }

