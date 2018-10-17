{
  stdenv,
  lib,
  writeText,
  writeScriptBin,
  libdot,
  sway, udev, gnupg,
  rofi, xorg, mako, persway,
  pulseaudioFull, coreutils, playerctl,
  spook, nix, edit, emacs-server, gnome3,
  terminal, fzf-window, fzf-run,
  fzf-passmenu, launch, rename-workspace,
  screenshot, settings, browse, rofi-passmenu,
  ...
}:

with lib;
with settings.sway;

let

  toOutputs = libdot.mapAttrsToMultilineString;

  loginctlPath = "${udev}/bin/loginctl";
  systemctlPath = "${udev}/bin/systemctl";
  rofiPath = "${rofi}/bin/rofi";
  xbacklightPath = "${xorg.xbacklight}/bin/xbacklight";
  inputWindowPath = "input-window";
  pactlPath = "${pulseaudioFull}/bin/pactl";
  killPath = "${coreutils}/bin/kill";
  catPath = "${coreutils}/bin/cat";
  spookPath = "${spook}/bin/spook";
  nixShellPath = "${nix}/bin/nix-shell";
  swayMsgPath = "${sway}/bin/swaymsg";
  playerctlPath = "${playerctl}/bin/playerctl";

  swayBarStatusCmd = writeScriptBin "swaybar-status" ''
    exec ${nixShellPath} --command "${spookPath} \
         -p $XDG_RUNTIME_DIR/moonbar.pid -r 0 -w ~/Development/moonbar" \
         ~/Development/moonbar/shell.nix
  '';

  config = writeText "sway-config" ''
    ######## Settings etc
    font ${font}

    for_window [class="fzf-window"] fullscreen enable
    for_window [title="fzf-window"] fullscreen enable
    for_window [class="input-window"] floating enable
    for_window [class="gcr-prompter"] floating enable
    no_focus [window_role="browser"]

    workspace_auto_back_and_forth yes
    default_border pixel 0
    default_floating_border pixel 0
    hide_edge_borders smart
    focus_follows_mouse yes
    focus_on_window_activation smart
    popup_during_fullscreen smart
    mouse_warping container

    ${toOutputs sway-outputs (name: value: '' output ${name} ${value} '')}

    input "1739:30383:DLL075B:01_06CB:76AF_Touchpad" {
      dwt enabled
      tap enabled
      natural_scroll enabled
      # middle_emulation enabled
    }

    input "1118:2354:Surface_Arc_Mouse_Keyboard" {
      dwt enabled
      # tap enabled
      natural_scroll enabled
      # middle_emulation enabled
    }

    # class                   border             background text         indicator          child_border
    client.focused            ${inactiveBgColor} ${bgColor} ${textColor} ${indicatorColor}  ${indicatorColor}
    client.focused_inactive   ${inactiveBgColor} ${inactiveBgColor} ${inactiveTextColor} ${indicatorColor} ${indicatorColor}
    client.unfocused          ${inactiveBgColor} ${inactiveBgColor} ${inactiveTextColor} ${indicatorColor} ${indicatorColor}
    client.urgent             ${urgentBgColor} ${urgentBgColor} ${textColor} ${indicatorColor} ${indicatorColor}

    ######## Key bindings

    # lock the screen
    bindsym Control+${mod}+l exec ${sway}/bin/swaylock ${swaylockArgs}

    # take a screenshot (stored in ~/Pictures/screenshots as a png)
    # bindsym ${mod}+x exec ${screenshot}/bin/screenshot

    # start a terminal
    bindsym ${mod}+Return exec _SET_WS_NAME=y _USE_NAME=term ${launch}/bin/launch ${terminal}/bin/terminal

    # start a light bg terminal
    # bindsym ${mod}+Shift+Return exec _SET_WS_NAME=y _USE_NAME=term ${launch}/bin/launch ${terminal}/bin/terminal-light

    # start a light + large font terminal
    # bindsym ${mod}+Control+Return exec _SET_WS_NAME=y _USE_NAME=term ${launch}/bin/launch ${terminal}/bin/terminal-large

    # use fzf as a program launcher
    # bindsym ${mod}+d exec ${fzf-window}/bin/fzf-window ${fzf-run}/bin/fzf-run
    bindsym ${mod}+d exec ${rofiPath} -show run -run-command "launch {cmd}"

    # use rofi for switching between windows
    bindsym ${mod}+Tab exec ${rofiPath} -show window -matching normal

    # passmenu
    # bindsym ${mod}+minus exec ${fzf-window}/bin/fzf-window ${fzf-passmenu}/bin/fzf-passmenu
    bindsym ${mod}+minus exec ${rofi-passmenu}/bin/rofi-passmenu

    # passmenu pass only
    # bindsym ${mod}+Shift+minus exec passonly=y ${fzf-window}/bin/fzf-window ${fzf-passmenu}/bin/fzf-passmenu

    # passmenu pass only no submit
    # bindsym ${mod}+Control+minus exec nosubmit=y passonly=y ${fzf-window}/bin/fzf-window ${fzf-passmenu}/bin/fzf-passmenu

    # create new password input
    # bindsym ${mod}+Shift+m exec ${inputWindowPath} "read-input login | xargs -I{} new-password {}"

    # (new empty emacs window really - starts server if not running)
    bindsym ${mod}+Shift+e exec ${edit}/bin/edit -e '(insane-new-empty-buffer)'

    # new browser
    bindsym ${mod}+Shift+b exec ${browse}/bin/browse

    # rename workspace
    bindsym ${mod}+n exec --no-startup-id ${rofiPath} -no-fullscreen -width 50 -lines 1 -padding 10 -show "Rename workspace" -modi "Rename workspace":${rename-workspace}/bin/rename-workspace

    # actually toggle between left/right screen
    bindsym ${mod}+m move workspace to output right

    # kill focused window
    bindsym ${mod}+Shift+q kill

    # scratchpad
    bindsym ${mod}+s scratchpad show
    bindsym ${mod}+Shift+s move scratchpad

    # screen brightness controls
    bindsym XF86MonBrightnessUp exec ${xbacklightPath} -inc 5
    bindsym XF86MonBrightnessDown exec ${xbacklightPath} -dec 5

    bindsym XF86AudioRaiseVolume exec --no-startup-id ${killPath} -USR1 $(${catPath} $XDG_RUNTIME_DIR/moonbar.pid)
    bindsym XF86AudioLowerVolume exec --no-startup-id ${killPath} -USR2 $(${catPath} $XDG_RUNTIME_DIR/moonbar.pid)
    bindsym XF86AudioMute exec --no-startup-id ${killPath} -HUP $(${catPath} $XDG_RUNTIME_DIR/moonbar.pid)

    bindsym XF86AudioPlay exec --no-startup-id ${playerctlPath} play-pause
    bindsym XF86AudioNext exec --no-startup-id ${playerctlPath} next
    bindsym XF86AudioPrev exec --no-startup-id ${playerctlPath} previous

    # change focus
    bindsym ${mod}+Left focus left
    bindsym ${mod}+Down focus down
    bindsym ${mod}+Up focus up
    bindsym ${mod}+Right focus right

    # alternatively, the cursor keys:
    bindsym ${mod}+Shift+Left move left
    bindsym ${mod}+Shift+Down move down
    bindsym ${mod}+Shift+Up move up
    bindsym ${mod}+Shift+Right move right

    # split in vertical orientation
    bindsym ${mod}+v split v

    # split in horizontal orientation
    bindsym ${mod}+Shift+v split h

    # enter fullscreen mode for the focused container
    bindsym ${mod}+f fullscreen

    # change container layout (stacked, tabbed, toggle split)
    bindsym ${mod}+q layout stacking
    bindsym ${mod}+w layout tabbed
    bindsym ${mod}+e layout toggle split

    # toggle tiling / floating
    bindsym ${mod}+Shift+space floating toggle

    # use mouse + $mod to drag floating windows to their wanted position
    floating_modifier ${mod}

    # center floating container
    bindsym ${mod}+o move absolute position center

    # change focus between tiling / floating windows
    bindsym ${mod}+space focus mode_toggle

    # focus the parent container
    bindsym ${mod}+a focus parent

    # workspace shortcuts
    bindsym ${mod}+1 workspace number 1
    bindsym ${mod}+2 workspace number 2
    bindsym ${mod}+3 workspace number 3
    bindsym ${mod}+4 workspace number 4
    bindsym ${mod}+5 workspace number 5
    bindsym ${mod}+6 workspace number 6
    bindsym ${mod}+7 workspace number 7
    bindsym ${mod}+8 workspace number 8
    bindsym ${mod}+9 workspace number 9
    bindsym ${mod}+0 workspace number 10

    # move focused container to workspace
    bindsym ${mod}+Shift+1 move container to workspace number 1
    bindsym ${mod}+Shift+2 move container to workspace number 2
    bindsym ${mod}+Shift+3 move container to workspace number 3
    bindsym ${mod}+Shift+4 move container to workspace number 4
    bindsym ${mod}+Shift+5 move container to workspace number 5
    bindsym ${mod}+Shift+6 move container to workspace number 6
    bindsym ${mod}+Shift+7 move container to workspace number 7
    bindsym ${mod}+Shift+8 move container to workspace number 8
    bindsym ${mod}+Shift+9 move container to workspace number 9
    bindsym ${mod}+Shift+0 move container to workspace number 10

    bindsym ${mod}+z workspace back_and_forth

    bindsym ${mod}+h focus left
    bindsym ${mod}+j focus up
    bindsym ${mod}+k focus down
    bindsym ${mod}+l focus right

    # reload the configuration file
    bindsym ${mod}+Shift+c reload

    # restart
    bindsym ${mod}+Shift+r restart

    ######## Modes

    # resize window (you can also use the mouse for that)
    mode "resize" {
            # These bindings trigger as soon as you enter the resize mode

            # Pressing left will shrink the window's width.
            # Pressing right will grow the window's width.
            # Pressing up will shrink the window's height.
            # Pressing down will grow the window's height.

            bindsym Left resize shrink width 10 px or 10 ppt
            bindsym Right resize grow width 10 px or 10 ppt
            bindsym Up resize shrink height 10 px or 10 ppt
            bindsym Down resize grow height 10 px or 10 ppt

            # back to normal: Enter or Escape
            bindsym Return mode "default"
            bindsym Escape mode "default"
    }
    bindsym ${mod}+r mode "resize"

    # system eg. suspend, logout, reboot, poweroff
    mode "(p)oweroff, (s)uspend, (r)eboot, (l)ogout" {
            # These bindings trigger as soon as you enter the system mode

            bindsym p exec "${swayMsgPath} mode 'default' && ${udev}/bin/systemctl poweroff"
            bindsym s exec "${swayMsgPath} mode 'default' && ${udev}/bin/systemctl suspend"
            bindsym r exec "${swayMsgPath} mode 'default' && ${udev}/bin/systemctl reboot"
            bindsym l exec "${swayMsgPath} exit"

            # back to normal: Enter or Escape
            bindsym Return mode "default"
            bindsym Escape mode "default"
    }
    bindsym ${mod}+Escape mode "(p)oweroff, (s)uspend, (r)eboot, (l)ogout"

    ######## Autostart

    exec ${xorg.xrdb}/bin/xrdb -merge ~/.Xresources

    # locks the screen on sleep etc
    exec ${sway}/bin/swayidle \
      timeout ${swaylockTimeout} 'test -e .inhibit-idle || ${sway}/bin/swaylock ${swaylockArgs}' \
      timeout ${swaylockSleepTimeout} 'test -e .inhibit-idle || ${sway}/bin/swaymsg "output * dpms off"' \
      resume '${sway}/bin/swaymsg "output * dpms on"' \
      before-sleep '${sway}/bin/swaylock ${swaylockArgs}'

    exec ${mako}/bin/mako --font ${makoConfig.font} --background-color "${makoConfig.backgroundColor}" --border-size ${makoConfig.borderSize} --default-timeout ${makoConfig.defaultTimeout} --padding ${makoConfig.padding} --height ${makoConfig.height} --width ${makoConfig.width} --markup 1

    exec ${persway}/bin/persway

    #exec --no-startup-id ${gnome3.gnome_settings_daemon}/libexec/gsd-xsettings

    exec echo "UPDATESTARTUPTTY" | ${gnupg}/bin/gpg-connect-agent > /dev/null 2>&1

    exec ${emacs-server}/bin/emacs-server --force

    ######### Bar
    bar {

      colors {
          # Whole color settings
          background ${inactiveBgColor}
          statusline ${barStatuslineColor}
          separator ${barSeparatorColor}

          focused_workspace ${barFocusedWorkspaceColorBorder} ${barFocusedWorkspaceColorBackground} ${barFocusedWorkspaceColorText}
          active_workspace ${barActiveWorkspaceColorBorder} ${barActiveWorkspaceColorBackground} ${barActiveWorkspaceColorText}
          inactive_workspace ${barInactiveWorkspaceColorBorder} ${barInactiveWorkspaceColorBackground} ${barInactiveWorkspaceColorText}
          urgent_workspace ${barUrgentWorkspaceColorBorder} ${barUrgentWorkspaceColorBackground} ${barUrgentWorkspaceColorText}
      }

      # tray_output primary
      status_command ${swayBarStatusCmd}/bin/swaybar-status
    }

  '';

in


  {
    __toString = self: ''
      ${libdot.mkdir { path = ".config/sway"; }}
      ${libdot.copy { path = config; to = ".config/sway/config";  }}
    '';
  }