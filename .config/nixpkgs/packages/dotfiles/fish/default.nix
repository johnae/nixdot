{stdenv, writeText, fzf, ...}:

let

  config = writeText "config.fish" ''
     set -x TERM xterm-256color
     set fish_color_error ff8a00

     # c0 to c4 progress from dark to bright
     # ce is the error colour
     set -g c0 (set_color 005284)
     set -g c1 (set_color 0075cd)
     set -g c2 (set_color 009eff)
     set -g c3 (set_color 6dc7ff)
     set -g c4 (set_color ffffff)
     set -g ce (set_color $fish_color_error)

     # remove greeting
     set fish_greeting

     # aliases (in fish these are actually translated to functions)
     ## manage home
     alias home="env GIT_DIR=$HOME/.cfg GIT_WORK_TREE=$HOME git"

     fish_vi_key_bindings

     function fish_prompt
       set fish_color_host --bold white
       set -l last_status $status
       if not set -q __fish_git_prompt_show_informative_status
         set -g __fish_git_prompt_show_informative_status 1
       end
       if not set -q __fish_git_prompt_color_branch
         set -g __fish_git_prompt_color_branch brmagenta
       end
       if not set -q __fish_git_prompt_showupstream
         set -g __fish_git_prompt_showupstream "informative"
       end
       if not set -q __fish_git_prompt_showdirtystate
         set -g __fish_git_prompt_showdirtystate "yes"
       end
       if not set -q __fish_git_prompt_color_stagedstate
         set -g __fish_git_prompt_color_stagedstate yellow
       end
       if not set -q __fish_git_prompt_color_invalidstate
         set -g __fish_git_prompt_color_invalidstate red
       end
       if not set -q __fish_git_prompt_color_cleanstate
         set -g __fish_git_prompt_color_cleanstate brgreen
       end

       printf '%s%s %s%s%s%s ' (set_color $fish_color_host) (prompt_hostname) (set_color $fish_color_cwd) (prompt_pwd) (set_color normal) (__fish_git_prompt)
       if not test $last_status -eq 0
         set_color $fish_color_error
       end
       echo -n '$ '
       set_color normal
     end

     function fish_mode_prompt --description 'Displays the current mode'
       # Do nothing if not in vi mode
       if test "$fish_key_bindings" = "fish_vi_key_bindings"
         switch $fish_bind_mode
           case default
             set_color normal
             printf "["
             set_color --bold blue
             printf "N"
             set_color normal
             printf "]"
           case insert
             set_color normal
             printf "["
             set_color --bold green
             printf "I"
             set_color normal
             printf "]"
           case replace-one
             set_color normal
             printf "["
             set_color --bold red
             printf "R"
             set_color normal
             printf "]"
           case visual
             set_color normal
             printf "["
             set_color --bold brmagenta
             printf "V"
             set_color normal
             printf "]"
         end
         set_color normal
         printf " "
       end
     end
  '';

  fzfConfig = writeText "fish_user_key_bindings.fish" ''
     source ${fzf}/share/fzf/key-bindings.fish
     function fish_user_key_bindings
       fzf_key_bindings
       function fzf-jump-to-project-widget -d "Show list of projects"
         set -q FZF_TMUX_HEIGHT; or set FZF_TMUX_HEIGHT 40%
         begin
           set -lx FZF_DEFAULT_OPTS "--height $FZF_TMUX_HEIGHT $FZF_DEFAULT_OPTS --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS +m"
           set -lx dir (project-select ~/Development)
           if [ "$dir" != "" ]
             cd $dir
           end
         end
         commandline -f repaint
       end
       bind \cg fzf-jump-to-project-widget
       if bind -M insert > /dev/null 2>&1
         bind -M insert \cg fzf-jump-to-project-widget
       end
     end
   '';

in

  { paths = {
        ".config/fish/config.fish" = config;
        ".config/fish/functions/fish_user_key_bindings.fish" = fzfConfig;
        };
  }