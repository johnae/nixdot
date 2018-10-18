{stdenv, libdot, writeText, fzf, fetchFromGitHub, ...}:

let

  config = writeText "config.fish" ''

     if test "$TERM" = "xterm-termite"
       set -x TERM termite
     end

     if test "$DISPLAY" = ""; and test (tty) = /dev/tty1; and test "$XDG_SESSION_TYPE" = ""
        exec start-sway
     end

     echo "UPDATESTARTUPTTY" | gpg-connect-agent > /dev/null 2>&1

     if test "$TERM" = "dumb"
        function fish_title; end
     end

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

     # emacs socket
     set -x EMACS_SERVER_FILE /run/user/1337/emacs1337/server

     # aliases (in fish these are actually translated to functions)
     ## manage home
     alias home="env GIT_DIR=$HOME/.cfg GIT_WORK_TREE=$HOME git"
     alias untracked="git ls-files --others --exclude-standard"

     fish_vi_key_bindings ^ /dev/null

     function clear_direnv_cache
       echo "Clearing direnv cache"
       fd --type d -I -H '\.direnv$' ~/Development/ | xargs rm -rf
       date +%s > ~/.direnv_cache_cleared
     end

     ## auto clear after 20 hours
     if not test -e ~/.direnv_cache_cleared; or test (math (date +%s) " - " (cat ~/.direnv_cache_cleared)) -ge 72000
        clear_direnv_cache
     end

     function reload_fish_config --on-signal HUP
       eval exec $SHELL
     end

     function fish_prompt
       set -l last_status $status
       set fish_color_host --bold white

       if [ "$PWD" = "$HOME" ];
          set -gx GIT_DIR $HOME/.cfg
          set -gx GIT_WORK_TREE $HOME
       end

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

       set -g prompt_status ""
       if [ $last_status -ne 0 ]
          set -g prompt_status "<$last_status> "
       end

       printf '%s%s%s %s%s%s%s> ' (set_color $fish_color_error)$prompt_status (set_color $fish_color_cwd)(prompt_pwd) (set_color normal)(__fish_git_prompt)
       if not test $last_status -eq 0
         set_color $fish_color_error
       end
       set_color normal

       if [ "$PWD" = "$HOME" ];
          set -e GIT_DIR
          set -e GIT_WORK_TREE
       end
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

   gcloudSrc = fetchFromGitHub {
     owner = "Doctusoft";
     repo = "google-cloud-sdk-fish-completion";
     rev = "bc24b0bf7da2addca377d89feece4487ca0b1e9c";
     sha256 = "03zzggi64fhk0yx705h8nbg3a02zch9y49cdvzgnmpi321vz71h4";
   };

   kubectlCompletions = fetchFromGitHub {
     owner = "evanlucas";
     repo = "fish-kubectl-completions";
     rev = "c870a143c5af2ac5a8174173a96e110a7677637f";
     sha256 = "0cn8k6axfrglvy7x3sw63g08cgxfq3z4jqxfxm05558qfc8hfhc2";
   };

in

  {
    __toString = self: ''
      ${libdot.mkdir { path = ".config/fish/functions"; }}
      ${libdot.mkdir { path = ".config/fish/completions"; }}
      ${libdot.copy { path = config; to = ".config/fish/config.fish";  }}
      ${libdot.copy { path = fzfConfig; to = ".config/fish/functions/fish_user_key_bindings.fish";  }}
      ${libdot.copy { path = "${gcloudSrc}/functions/gcloud_sdk_argcomplete.fish"; to = ".config/fish/functions/gcloud_sdk_argcomplete.fish";  }}
      ${libdot.copy { path = "${kubectlCompletions}/kubectl.fish"; to = ".config/fish/completions/kubectl.fish"; }}
      ${libdot.copy { path = "${gcloudSrc}/completions/gcloud.fish"; to = ".config/fish/completions/gcloud.fish"; }}
      ${libdot.copy { path = "${gcloudSrc}/completions/gsutil.fish"; to = ".config/fish/completions/gsutil.fish"; }}
    '';
  }
