{stdenv, libdot, writeText, skim, fd, lsd, edi, fetchFromGitHub, ...}:

let

  config = writeText "config.fish" ''

     if test "$TERM" = "xterm-termite"
       set -x TERM termite
     end

     function i
       nix-env -iA nixos.$argv
     end

     function s
       nix-env -qaP ".*$argv.*"
     end

     complete -c home -w git

     if not set -q abbrs_initialized
       set -U abbrs_initialized
       echo -n Setup abbreviations...

       abbr cat bat
       abbr hr 'nix-env -iA nixos.home; and home-update'

       abbr g 'git'
       abbr ga 'git add'
       abbr gb 'git branch'
       abbr gbl 'git blame'
       abbr gc 'git commit -m'
       abbr gco 'git checkout'
       abbr gcp 'git cherry-pick'
       abbr gd 'git diff'
       abbr gf 'git fetch'
       abbr gl 'git log'
       abbr gm 'git merge'
       abbr gp 'git push'
       abbr gpl 'git pull'
       abbr gr 'git remote'
       abbr gs 'git status'
       abbr gst 'git stash'

       echo 'Done'
     end

     # emacs socket
     set -x EMACS_SERVER_FILE /run/user/1337/emacs1337/server

     if test "$DISPLAY" = ""; and test (tty) = /dev/tty1; and test "$XDG_SESSION_TYPE" = "tty"
        exec start-sway
     end

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

     # aliases (in fish these are actually translated to functions)
     ## manage home
     alias home="env GIT_DIR=$HOME/.cfg GIT_WORK_TREE=$HOME git"
     alias untracked="git ls-files --others --exclude-standard"
     alias ls="${lsd}/bin/lsd --group-dirs first"

     fish_vi_key_bindings ^ /dev/null

     function clear_direnv_cache
       echo "Clearing direnv cache"
       fd --type d -I -H '\.direnv$' ~/Development/ | xargs rm -rf
       date +%s > ~/.direnv_cache_cleared
     end

     ## auto clear after 20 hours
     ## if not test -e ~/.direnv_cache_cleared; or test (math (date +%s) " - " (cat ~/.direnv_cache_cleared)) -ge 72000
     ##    clear_direnv_cache
     ## end

     function reload_fish_config --on-signal HUP
       eval exec $SHELL
     end

     function fish_prompt
       set -l last_status $status
       set fish_color_host --bold white

       if [ "$PWD" = "$HOME" ];
          set -gx GIT_DIR $HOME/.cfg
          set -gx GIT_WORK_TREE $HOME
          set -gx __nountracked 1
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

       printf '%s%s%s%s %s%s%s%s%s \n> ' (set_color $fish_color_error)$prompt_status (set_color --bold brmagenta)(_in_nix_shell)(set_color $fish_color_cwd)(prompt_pwd) (set_color normal)(__fish_git_prompt)(set_color green)(_kube_context)(set_color normal)
       if not test $last_status -eq 0
         set_color $fish_color_error
       end
       set_color normal

       if [ "$PWD" = "$HOME" ];
          set -e GIT_DIR
          set -e GIT_WORK_TREE
          set -e __nountracked
       end
     end

     function _in_nix_shell --description 'Returns whether we are in a nix shell'
       if [ "$IN_NIX_SHELL" = "" ]
         echo ""
       else
         echo "[NIX] "
       end
     end

     function _kube_context --description 'Returns the current kube context'
       if command -sq kubectl
         echo " "(cat ~/.config/gcloud/configurations/config_default | grep 'project =' | awk '{print $NF}')" | "(kubectl config current-context)/(kubectl config view --minify --output 'jsonpath={..context.namespace}')
       else
         echo ""
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

  skimConfig = writeText "fish_user_key_bindings.fish" ''
     source ${skim}/share/skim/key-bindings.fish
     function fish_user_key_bindings
       skim_key_bindings

       function skim-jump-to-project-widget -d "Show list of projects"
         set -q SK_TMUX_HEIGHT; or set SK_TMUX_HEIGHT 40%
         begin
           set -lx SK_DEFAULT_OPTS "--height $SK_TMUX_HEIGHT $SK_DEFAULT_OPTS --tiebreak=index --bind=ctrl-r:toggle-sort $SK_CTRL_R_OPTS +m"
           set -lx dir (project-select ~/Development)
           if [ "$dir" != "" ]
             cd $dir
             set -lx file (${fd}/bin/fd -H -E "\.git" . | "${skim}"/bin/sk)
             if [ "$file" != "" ]
               ${edi}/bin/edi "$file"
             end
           end
         end
         commandline -f repaint
       end
       bind \cg skim-jump-to-project-widget
       if bind -M insert > /dev/null 2>&1
         bind -M insert \cg skim-jump-to-project-widget
       end

       function kubectx-select -d "Select kubernetes cluster"
         if command -sq kubectx
           kubectx
         else
           echo Missing command kubectx
         end
       end
       bind \ck kubectx-select
       if bind -M insert > /dev/null 2>&1
         bind -M insert \ck kubectx-select
       end

       function gcloud-project-select -d "Select gcloud project"
         if command -sq gcloud
         set proj (gcloud projects list | tail -n +2 | awk '{print $1}' | "${skim}"/bin/sk)
           gcloud config set project $proj
         else
           echo Missing command gcloud
         end
       end
       bind \cw gcloud-project-select
       if bind -M insert > /dev/null 2>&1
         bind -M insert \cw gcloud-project-select
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

   fishGitPrompt = writeText "__fish_git_prompt.fish" ''

     function __fish_git_prompt_show_upstream --description "Helper function for __fish_git_prompt"
         set -q __fish_git_prompt_showupstream
         or set -l __fish_git_prompt_showupstream
         set -l show_upstream $__fish_git_prompt_showupstream
         set -l svn_prefix # For better SVN upstream information
         set -l informative

         set -l svn_url_pattern
         set -l count
         set -l upstream git
         set -l verbose
         set -l name

         # Default to informative if __fish_git_prompt_show_informative_status is set
         if set -q __fish_git_prompt_show_informative_status
             set informative 1
         end

         set -l svn_remote
         # get some config options from git-config
         command git config -z --get-regexp '^(svn-remote\..*\.url|bash\.showupstream)$' 2>/dev/null | while read -lz key value
             switch $key
                 case bash.showupstream
                     set show_upstream $value
                     test -n "$show_upstream"
                     or return
                 case svn-remote.'*'.url
                     set svn_remote $svn_remote $value
                     # Avoid adding \| to the beginning to avoid needing #?? later
                     if test -n "$svn_url_pattern"
                         set svn_url_pattern $svn_url_pattern"|$value"
                     else
                         set svn_url_pattern $value
                     end
                     set upstream svn+git # default upstream is SVN if available, else git

                     # Save the config key (without .url) for later use
                     set -l remote_prefix (string replace -r '\.url$' "" -- $key)
                     set svn_prefix $svn_prefix $remote_prefix
             end
         end

         # parse configuration variables
         # and clear informative default when needed
         for option in $show_upstream
             switch $option
                 case git svn
                     set upstream $option
                     set -e informative
                 case verbose
                     set verbose 1
                     set -e informative
                 case informative
                     set informative 1
                 case name
                     set name 1
                 case none
                     return
             end
         end

         # Find our upstream
         switch $upstream
             case git
                 set upstream '@{upstream}'
             case svn\*
                 # get the upstream from the 'git-svn-id: …' in a commit message
                 # (git-svn uses essentially the same procedure internally)
                 set -l svn_upstream (git log --first-parent -1 --grep="^git-svn-id: \($svn_url_pattern\)" 2>/dev/null)
                 if test (count $svn_upstream) -ne 0
                     echo $svn_upstream[-1] | read -l __ svn_upstream __
                     set svn_upstream (string replace -r '@.*' "" -- $svn_upstream)
                     set -l cur_prefix
                     for i in (seq (count $svn_remote))
                         set -l remote $svn_remote[$i]
                         set -l mod_upstream (string replace "$remote" "" -- $svn_upstream)
                         if test "$svn_upstream" != "$mod_upstream"
                             # we found a valid remote
                             set svn_upstream $mod_upstream
                             set cur_prefix $svn_prefix[$i]
                             break
                         end
                     end

                     if test -z "$svn_upstream"
                         # default branch name for checkouts with no layout:
                         if test -n "$GIT_SVN_ID"
                             set upstream $GIT_SVN_ID
                         else
                             set upstream git-svn
                         end
                     else
                         set upstream (string replace '/branches' "" -- $svn_upstream | string replace -a '/' "")

                         # Use fetch config to fix upstream
                         set -l fetch_val (command git config "$cur_prefix".fetch)
                         if test -n "$fetch_val"
                             string split -m1 : -- "$fetch_val" | read -l trunk pattern
                             set upstream (string replace -r -- "/$trunk\$" "" $pattern) /$upstream
                         end
                     end
                 else if test $upstream = svn+git
                     set upstream '@{upstream}'
                 end
         end

         # Find how many commits we are ahead/behind our upstream
         set count (command git rev-list --count --left-right $upstream...HEAD 2>/dev/null)

         # calculate the result
         if test -n "$verbose"
             # Verbose has a space by default
             set -l prefix "$___fish_git_prompt_char_upstream_prefix"
             # Using two underscore version to check if user explicitly set to nothing
             if not set -q __fish_git_prompt_char_upstream_prefix
                 set -l prefix " "
             end

             echo $count | read -l behind ahead
             switch "$count"
                 case "" # no upstream
                 case "0	0" # equal to upstream
                     echo "$prefix$___fish_git_prompt_char_upstream_equal"
                 case "0	*" # ahead of upstream
                     echo "$prefix$___fish_git_prompt_char_upstream_ahead$ahead"
                 case "*	0" # behind upstream
                     echo "$prefix$___fish_git_prompt_char_upstream_behind$behind"
                 case '*' # diverged from upstream
                     echo "$prefix$___fish_git_prompt_char_upstream_diverged$ahead-$behind"
             end
             if test -n "$count" -a -n "$name"
                 echo " "(command git rev-parse --abbrev-ref "$upstream" 2>/dev/null)
             end
         else if test -n "$informative"
             echo $count | read -l behind ahead
             switch "$count"
                 case "" # no upstream
                 case "0	0" # equal to upstream
                 case "0	*" # ahead of upstream
                     echo "$___fish_git_prompt_char_upstream_prefix$___fish_git_prompt_char_upstream_ahead$ahead"
                 case "*	0" # behind upstream
                     echo "$___fish_git_prompt_char_upstream_prefix$___fish_git_prompt_char_upstream_behind$behind"
                 case '*' # diverged from upstream
                     echo "$___fish_git_prompt_char_upstream_prefix$___fish_git_prompt_char_upstream_ahead$ahead$___fish_git_prompt_char_upstream_behind$behind"
             end
         else
             switch "$count"
                 case "" # no upstream
                 case "0	0" # equal to upstream
                     echo "$___fish_git_prompt_char_upstream_prefix$___fish_git_prompt_char_upstream_equal"
                 case "0	*" # ahead of upstream
                     echo "$___fish_git_prompt_char_upstream_prefix$___fish_git_prompt_char_upstream_ahead"
                 case "*	0" # behind upstream
                     echo "$___fish_git_prompt_char_upstream_prefix$___fish_git_prompt_char_upstream_behind"
                 case '*' # diverged from upstream
                     echo "$___fish_git_prompt_char_upstream_prefix$___fish_git_prompt_char_upstream_diverged"
             end
         end
     end

     function __fish_git_prompt --description "Prompt function for Git"
         # If git isn't installed, there's nothing we can do
         # Return 1 so the calling prompt can deal with it
         if not command -sq git
             return 1
         end
         set -l repo_info (command git rev-parse --git-dir --is-inside-git-dir --is-bare-repository --is-inside-work-tree HEAD 2>/dev/null)
         test -n "$repo_info"
         or return

         set -l git_dir $repo_info[1]
         set -l inside_gitdir $repo_info[2]
         set -l bare_repo $repo_info[3]
         set -l inside_worktree $repo_info[4]
         set -q repo_info[5]
         and set -l sha $repo_info[5]

         set -l rbc (__fish_git_prompt_operation_branch_bare $repo_info)
         set -l r $rbc[1] # current operation
         set -l b $rbc[2] # current branch
         set -l detached $rbc[3]
         set -l w #dirty working directory
         set -l i #staged changes
         set -l s #stashes
         set -l u #untracked
         set -l c $rbc[4] # bare repository
         set -l p #upstream
         set -l informative_status

         if not set -q ___fish_git_prompt_init
             # This takes a while, so it only needs to be done once,
             # and then whenever the configuration changes.
             __fish_git_prompt_validate_chars
             __fish_git_prompt_validate_colors
             set -g ___fish_git_prompt_init
         end

         set -l space "$___fish_git_prompt_color$___fish_git_prompt_char_stateseparator$___fish_git_prompt_color_done"

         if test "true" = $inside_worktree
             if set -q __fish_git_prompt_show_informative_status
                 set informative_status "$space"(__fish_git_prompt_informative_status)
             else
                 if set -q __fish_git_prompt_showdirtystate
                     set -l config (command git config --bool bash.showDirtyState)
                     if test "$config" != "false"
                         set w (__fish_git_prompt_dirty)
                         set i (__fish_git_prompt_staged $sha)
                     end
                 end

                 if set -q __fish_git_prompt_showstashstate
                     and test -r $git_dir/refs/stash
                     set s $___fish_git_prompt_char_stashstate
                 end

                 if set -q __fish_git_prompt_showuntrackedfiles
                     set -l config (command git config --bool bash.showUntrackedFiles)
                     if test "$config" != false
                         set u (__fish_git_prompt_untracked)
                     end
                 end
             end

             if set -q __fish_git_prompt_showupstream
                 or set -q __fish_git_prompt_show_informative_status
                 set p (__fish_git_prompt_show_upstream)
             end
         end

         set -l branch_color $___fish_git_prompt_color_branch
         set -l branch_done $___fish_git_prompt_color_branch_done
         if set -q __fish_git_prompt_showcolorhints
             if test $detached = yes
                 set branch_color $___fish_git_prompt_color_branch_detached
                 set branch_done $___fish_git_prompt_color_branch_detached_done
             end
         end

         if test -n "$w"
             set w "$___fish_git_prompt_color_dirtystate$w$___fish_git_prompt_color_dirtystate_done"
         end
         if test -n "$i"
             set i "$___fish_git_prompt_color_stagedstate$i$___fish_git_prompt_color_stagedstate_done"
         end
         if test -n "$s"
             set s "$___fish_git_prompt_color_stashstate$s$___fish_git_prompt_color_stashstate_done"
         end
         if test -n "$u"
             set u "$___fish_git_prompt_color_untrackedfiles$u$___fish_git_prompt_color_untrackedfiles_done"
         end

         set b (string replace refs/heads/ "" -- $b)
         set -q __fish_git_prompt_shorten_branch_char_suffix
         or set -l __fish_git_prompt_shorten_branch_char_suffix "…"
         if string match -qr '^\d+$' "$__fish_git_prompt_shorten_branch_len"; and test (string length "$b") -gt $__fish_git_prompt_shorten_branch_len
             set b (string sub -l "$__fish_git_prompt_shorten_branch_len" "$b")"$__fish_git_prompt_shorten_branch_char_suffix"
         end
         if test -n "$b"
             set b "$branch_color$b$branch_done"
         end

         if test -n "$c"
             set c "$___fish_git_prompt_color_bare$c$___fish_git_prompt_color_bare_done"
         end
         if test -n "$r"
             set r "$___fish_git_prompt_color_merging$r$___fish_git_prompt_color_merging_done"
         end
         if test -n "$p"
             set p "$___fish_git_prompt_color_upstream$p$___fish_git_prompt_color_upstream_done"
         end

         # Formatting
         set -l f "$w$i$s$u"
         if test -n "$f"
             set f "$space$f"
         end
         set -l format $argv[1]
         if test -z "$format"
             set format " (%s)"
         end

         printf "%s$format%s" "$___fish_git_prompt_color_prefix" "$___fish_git_prompt_color_prefix_done$c$b$f$r$p$informative_status$___fish_git_prompt_color_suffix" "$___fish_git_prompt_color_suffix_done"
     end

     ### helper functions

     function __fish_git_prompt_staged --description "__fish_git_prompt helper, tells whether or not the current branch has staged files"
         set -l sha $argv[1]

         set -l staged

         if test -n "$sha"
             command git diff-index --cached --quiet HEAD -- 2>/dev/null
             or set staged $___fish_git_prompt_char_stagedstate
         else
             set staged $___fish_git_prompt_char_invalidstate
         end
         echo $staged
     end

     function __fish_git_prompt_untracked --description "__fish_git_prompt helper, tells whether or not the current repository has untracked files"
         set -l untracked
         if command git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- :/ >/dev/null 2>&1
             set untracked $___fish_git_prompt_char_untrackedfiles
         end
         echo $untracked
     end

     function __fish_git_prompt_dirty --description "__fish_git_prompt helper, tells whether or not the current branch has tracked, modified files"
         set -l dirty

         set -l os
         command git diff --no-ext-diff --quiet --exit-code 2>/dev/null
         set os $status
         if test $os -ne 0
             set dirty $___fish_git_prompt_char_dirtystate
         end
         echo $dirty
     end

     set -g ___fish_git_prompt_status_order stagedstate invalidstate dirtystate untrackedfiles

     function __fish_git_prompt_informative_status

         set -l changedFiles (command git diff --name-status 2>/dev/null | string match -r \\w)
         set -l stagedFiles (command git diff --staged --name-status | string match -r \\w)

         set -l x (count $changedFiles)
         set -l y (count (string match -r "U" -- $changedFiles))
         set -l dirtystate (math $x - $y)
         set -l x (count $stagedFiles)
         set -l invalidstate (count (string match -r "U" -- $stagedFiles))
         set -l stagedstate (math $x - $invalidstate)
         set -l untrackedfiles "0"
         if test -z "$__nountracked"
           set -l untrackedfiles (command git ls-files --others --exclude-standard | wc -l | string trim)
         end

         set -l info

         # If `math` fails for some reason, assume the state is clean - it's the simpler path
         set -l state (math $dirtystate + $invalidstate + $stagedstate + $untrackedfiles 2>/dev/null)
         if test -z "$state"
             or test "$state" = 0
             set info $___fish_git_prompt_color_cleanstate$___fish_git_prompt_char_cleanstate$___fish_git_prompt_color_cleanstate_done
         else
             for i in $___fish_git_prompt_status_order
                 if [ $$i != "0" ]
                     set -l color_var ___fish_git_prompt_color_$i
                     set -l color_done_var ___fish_git_prompt_color_{$i}_done
                     set -l symbol_var ___fish_git_prompt_char_$i

                     set -l color $$color_var
                     set -l color_done $$color_done_var
                     set -l symbol $$symbol_var

                     set -l count

                     if not set -q __fish_git_prompt_hide_$i
                         set count $$i
                     end

                     set info "$info$color$symbol$count$color_done"
                 end
             end
         end

         echo $info

     end

     # Keeping these together avoids many duplicated checks
     function __fish_git_prompt_operation_branch_bare --description "__fish_git_prompt helper, returns the current Git operation and branch"
         # This function is passed the full repo_info array
         set -l git_dir $argv[1]
         set -l inside_gitdir $argv[2]
         set -l bare_repo $argv[3]
         set -q argv[5]
         and set -l sha $argv[5]

         set -l branch
         set -l operation
         set -l detached no
         set -l bare
         set -l step
         set -l total
         set -l os

         if test -d $git_dir/rebase-merge
             set branch (cat $git_dir/rebase-merge/head-name 2>/dev/null)
             set step (cat $git_dir/rebase-merge/msgnum 2>/dev/null)
             set total (cat $git_dir/rebase-merge/end 2>/dev/null)
             if test -f $git_dir/rebase-merge/interactive
                 set operation "|REBASE-i"
             else
                 set operation "|REBASE-m"
             end
         else
             if test -d $git_dir/rebase-apply
                 set step (cat $git_dir/rebase-apply/next 2>/dev/null)
                 set total (cat $git_dir/rebase-apply/last 2>/dev/null)
                 if test -f $git_dir/rebase-apply/rebasing
                     set branch (cat $git_dir/rebase-apply/head-name 2>/dev/null)
                     set operation "|REBASE"
                 else if test -f $git_dir/rebase-apply/applying
                     set operation "|AM"
                 else
                     set operation "|AM/REBASE"
                 end
             else if test -f $git_dir/MERGE_HEAD
                 set operation "|MERGING"
             else if test -f $git_dir/CHERRY_PICK_HEAD
                 set operation "|CHERRY-PICKING"
             else if test -f $git_dir/REVERT_HEAD
                 set operation "|REVERTING"
             else if test -f $git_dir/BISECT_LOG
                 set operation "|BISECTING"
             end
         end

         if test -n "$step" -a -n "$total"
             set operation "$operation $step/$total"
         end

         if test -z "$branch"
             set branch (command git symbolic-ref HEAD 2>/dev/null; set os $status)
             if test $os -ne 0
                 set detached yes
                 set branch (switch "$__fish_git_prompt_describe_style"
                case contains
                  command git describe --contains HEAD
                case branch
                  command git describe --contains --all HEAD
                case describe
                  command git describe HEAD
                case default '*'
                  command git describe --tags --exact-match HEAD
                end 2>/dev/null; set os $status)
                 if test $os -ne 0
                     # Shorten the sha ourselves to 8 characters - this should be good for most repositories,
                     # and even for large ones it should be good for most commits
                     if set -q sha
                         set branch (string match -r '^.{8}' -- $sha)…
                     else
                         set branch unknown
                     end
                 end
                 set branch "($branch)"
             end
         end

         if test "true" = $inside_gitdir
             if test "true" = $bare_repo
                 set bare "BARE:"
             else
                 # Let user know they're inside the git dir of a non-bare repo
                 set branch "GIT_DIR!"
             end
         end

         echo $operation
         echo $branch
         echo $detached
         echo $bare
     end

     function __fish_git_prompt_set_char
         set -l user_variable_name "$argv[1]"
         set -l char $argv[2]
         set -l user_variable
         if set -q $user_variable_name
             set user_variable $$user_variable_name
         end

         if set -q argv[3]
             and set -q __fish_git_prompt_show_informative_status
             set char $argv[3]
         end

         set -l variable _$user_variable_name
         set -l variable_done "$variable"_done

         if not set -q $variable
             set -g $variable (set -q $user_variable_name; and echo $user_variable; or echo $char)
         end
     end

     function __fish_git_prompt_validate_chars --description "__fish_git_prompt helper, checks char variables"

         __fish_git_prompt_set_char __fish_git_prompt_char_cleanstate '✔'
         __fish_git_prompt_set_char __fish_git_prompt_char_dirtystate '*' '✚'
         __fish_git_prompt_set_char __fish_git_prompt_char_invalidstate '#' '✖'
         __fish_git_prompt_set_char __fish_git_prompt_char_stagedstate '+' '●'
         __fish_git_prompt_set_char __fish_git_prompt_char_stashstate '$'
         __fish_git_prompt_set_char __fish_git_prompt_char_stateseparator ' ' '|'
         __fish_git_prompt_set_char __fish_git_prompt_char_untrackedfiles '%' '…'
         __fish_git_prompt_set_char __fish_git_prompt_char_upstream_ahead '>' '↑'
         __fish_git_prompt_set_char __fish_git_prompt_char_upstream_behind '<' '↓'
         __fish_git_prompt_set_char __fish_git_prompt_char_upstream_diverged '<>'
         __fish_git_prompt_set_char __fish_git_prompt_char_upstream_equal '='
         __fish_git_prompt_set_char __fish_git_prompt_char_upstream_prefix ""

     end

     function __fish_git_prompt_set_color
         set -l user_variable_name "$argv[1]"
         set -l user_variable
         if set -q $user_variable_name
             set user_variable $$user_variable_name
         end
         set -l user_variable_bright

         set -l default default_done
         switch (count $argv)
             case 1 # No defaults given, use prompt color
                 set default $___fish_git_prompt_color
                 set default_done $___fish_git_prompt_color_done
             case 2 # One default given, use normal for done
                 set default "$argv[2]"
                 set default_done (set_color normal)
             case 3 # Both defaults given
                 set default "$argv[2]"
                 set default_done "$argv[3]"
         end

         set -l variable _$user_variable_name
         set -l variable_done "$variable"_done

         if not set -q $variable
             if test -n "$user_variable"
                 set -g $variable (set_color $user_variable)
                 set -g $variable_done (set_color normal)
             else
                 set -g $variable $default
                 set -g $variable_done $default_done
             end
         end

     end


     function __fish_git_prompt_validate_colors --description "__fish_git_prompt helper, checks color variables"

         # Base color defaults to nothing (must be done first)
         __fish_git_prompt_set_color __fish_git_prompt_color "" ""

         # Normal colors
         __fish_git_prompt_set_color __fish_git_prompt_color_prefix
         __fish_git_prompt_set_color __fish_git_prompt_color_suffix
         __fish_git_prompt_set_color __fish_git_prompt_color_bare
         __fish_git_prompt_set_color __fish_git_prompt_color_merging
         __fish_git_prompt_set_color __fish_git_prompt_color_cleanstate
         __fish_git_prompt_set_color __fish_git_prompt_color_invalidstate
         __fish_git_prompt_set_color __fish_git_prompt_color_upstream

         # Colors with defaults with showcolorhints
         if set -q __fish_git_prompt_showcolorhints
             __fish_git_prompt_set_color __fish_git_prompt_color_flags (set_color --bold blue)
             __fish_git_prompt_set_color __fish_git_prompt_color_branch (set_color green)
             __fish_git_prompt_set_color __fish_git_prompt_color_dirtystate (set_color red)
             __fish_git_prompt_set_color __fish_git_prompt_color_stagedstate (set_color green)
         else
             __fish_git_prompt_set_color __fish_git_prompt_color_flags
             __fish_git_prompt_set_color __fish_git_prompt_color_branch
             __fish_git_prompt_set_color __fish_git_prompt_color_dirtystate $___fish_git_prompt_color_flags $___fish_git_prompt_color_flags_done
             __fish_git_prompt_set_color __fish_git_prompt_color_stagedstate $___fish_git_prompt_color_flags $___fish_git_prompt_color_flags_done
         end

         # Branch_detached has a default, but is only used with showcolorhints
         __fish_git_prompt_set_color __fish_git_prompt_color_branch_detached (set_color red)

         # Colors that depend on flags color
         __fish_git_prompt_set_color __fish_git_prompt_color_stashstate $___fish_git_prompt_color_flags $___fish_git_prompt_color_flags_done
         __fish_git_prompt_set_color __fish_git_prompt_color_untrackedfiles $___fish_git_prompt_color_flags $___fish_git_prompt_color_flags_done

     end

     set -l varargs
     #for var in repaint describe_style show_informative_status showdirtystate showstashstate showuntrackedfiles showupstream
     #    set -a varargs --on-variable __fish_git_prompt_$var
     #end
     function __fish_git_prompt_repaint $varargs --description "Event handler, repaints prompt when functionality changes"
         if status --is-interactive
             if test $argv[3] = __fish_git_prompt_show_informative_status
                 # Clear characters that have different defaults with/without informative status
                 for name in cleanstate dirtystate invalidstate stagedstate stateseparator untrackedfiles upstream_ahead upstream_behind
                     set -e ___fish_git_prompt_char_$name
                 end
             end

             commandline -f repaint 2>/dev/null
         end
     end

     set -l varargs
     #for var in "" _prefix _suffix _bare _merging _cleanstate _invalidstate _upstream _flags _branch _dirtystate _stagedstate _branch_detached _stashstate _untrackedfiles
     #    set -a varargs --on-variable __fish_git_prompt_color$var
     #end
     #set -a varargs --on-variable __fish_git_prompt_showcolorhints
     function __fish_git_prompt_repaint_color $varargs --description "Event handler, repaints prompt when any color changes"
         if status --is-interactive
             set -e ___fish_git_prompt_init
             set -l var $argv[3]
             set -e _$var
             set -e _{$var}_done
             if test $var = __fish_git_prompt_color -o $var = __fish_git_prompt_color_flags -o $var = __fish_git_prompt_showcolorhints
                 # reset all the other colors too
                 for name in prefix suffix bare merging branch dirtystate stagedstate invalidstate stashstate untrackedfiles upstream flags
                     set -e ___fish_git_prompt_color_$name
                     set -e ___fish_git_prompt_color_{$name}_done
                 end
             end
             commandline -f repaint 2>/dev/null
         end
     end

     set -l varargs
     #for var in cleanstate dirtystate invalidstate stagedstate stashstate stateseparator untrackedfiles upstream_ahead upstream_behind upstream_diverged upstream_equal upstream_prefix
     #    set -a varargs --on-variable __fish_git_prompt_char_$var
     #end
     function __fish_git_prompt_repaint_char $varargs --description "Event handler, repaints prompt when any char changes"
         if status --is-interactive
             set -e ___fish_git_prompt_init
             set -e _$argv[3]
             commandline -f repaint 2>/dev/null
         end
     end

   '';

in

  {
    __toString = self: ''
      ${libdot.mkdir { path = ".config/fish/functions"; }}
      ${libdot.mkdir { path = ".config/fish/completions"; }}
      ${libdot.copy { path = config; to = ".config/fish/config.fish";  }}
      ${libdot.copy { path = skimConfig; to = ".config/fish/functions/fish_user_key_bindings.fish";  }}
      ${libdot.copy { path = fishGitPrompt; to = ".config/fish/functions/__fish_git_prompt.fish"; }}
      ${libdot.copy { path = "${gcloudSrc}/functions/gcloud_sdk_argcomplete.fish"; to = ".config/fish/functions/gcloud_sdk_argcomplete.fish";  }}
      ${libdot.copy { path = "${kubectlCompletions}/kubectl.fish"; to = ".config/fish/completions/kubectl.fish"; }}
      ${libdot.copy { path = "${gcloudSrc}/completions/gcloud.fish"; to = ".config/fish/completions/gcloud.fish"; }}
      ${libdot.copy { path = "${gcloudSrc}/completions/gsutil.fish"; to = ".config/fish/completions/gsutil.fish"; }}
    '';
  }
