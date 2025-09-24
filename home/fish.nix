{ config, ... }:
{
  programs = {
    # FIXME: figure out atuin configuration better
    atuin = {
      enable = true;
      enableFishIntegration = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    direnv = {
      enable = true;
    };

    # FIXME: jana has fzf here also...

    fish = {
      enable = true;

      interactiveShellInit = ''
        ${config.programs.jujutsu.package}/bin/jj util completion fish | source
        fish_add_path "$HOME/.cargo/bin"
      '';

      functions = {
        fish_jj_prompt = {
          description = "Write out the jj part of the prompt";
          body = ''
            if not jj root --quiet &>/dev/null
                return 1
            end

            echo " ("
            jj log --reversed --ignore-working-copy --no-graph --color always \
                -r 'heads(::@ & bookmarks() & mutable())::@ | @' \
                -T '
              separate(
                "",
                bookmarks.join("|"),
                if(bookmarks.len() == 0, "+"),
                if(current_working_copy, " " ++ separate(
                  " ",
                  if(conflict, "conflict"),
                  if(empty, "empty"),
                  if(divergent, "divergent"),
                  if(hidden, "hidden"),
                ))
              )
            '
            echo ")"

            # I didn't find them useful...
            # change_id.shortest(),
            # commit_id.shortest(),
          '';
        };
        fish_vcs_prompt = {
          description = "Print all vcs prompts";
          body = ''
            # If a prompt succeeded, we assume that it's printed the correct info.
            # This is so we don't try git if jj already worked.
            fish_jj_prompt $argv
            or fish_git_prompt $argv
            # or fish_hg_prompt $argv
            # or fish_fossil_prompt $argv
            # ...
          '';
        };
        fish_prompt = {
          description = "Write out the prompt";
          body = ''
            set -l last_pipestatus $pipestatus
            set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
            set -l normal (set_color normal)
            set -q fish_color_status
            or set -g fish_color_status --background=red white

            # Color the prompt differently when we're root
            set -l color_cwd $fish_color_cwd
            set -l suffix ';'
            if functions -q fish_is_root_user; and fish_is_root_user
                if set -q fish_color_cwd_root
                    set color_cwd $fish_color_cwd_root
                end
            end

            # Write pipestatus
            # If the status was carried over (if no command is issued or if `set` leaves the status untouched), don't bold it.
            set -l bold_flag --bold
            set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
            if test $__fish_prompt_status_generation = $status_generation
                set bold_flag
            end
            set __fish_prompt_status_generation $status_generation
            set -l status_color (set_color $fish_color_status)
            set -l statusb_color (set_color $bold_flag $fish_color_status)
            set -l prompt_status (__fish_print_pipestatus "[" "]" "|" "$status_color" "$statusb_color" $last_pipestatus)

            echo -n -s ': ' (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal " "$prompt_status $suffix " "
            # echo -n -s "; "
          '';
        };
      };
    };
  };
}
