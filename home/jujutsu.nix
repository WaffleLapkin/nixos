{
  lib,
  pkgs,
  pkgs-unstable,
  params,
  ...
}:
{
  programs.jjui = {
    enable = true;
  };

  home.packages = [
    pkgs.watchman
  ];

  programs.jujutsu = {
    enable = true;
    package = pkgs-unstable.jujutsu;
    settings = {
      user.name = "Waffle Lapkin";
      user.email = "waffle.lapkin@gmail.com";

      ui.default-command = [
        "log"
        "--reversed"
        "--no-pager"
      ];
      colors.waffle_subheading.italic = true;

      ui.diff-editor = ":builtin";

      ui.pager = "delta";
      ui.diff-formatter = ":git"; # for delta

      revset-aliases = {
        "my()" = "user(exact:\"waffle.lapkin@gmail.com\")";
        "user(x)" = "author(x) | committer(x)";
      };

      # <https://willhbr.net/2024/08/18/understanding-revsets-for-a-better-jj-log-output/>
      # log = '@ | ancestors(trunk()..(visible_heads() & mine()), 2) | trunk()'
      # log = '@ | ancestors(trunk()..(visible_heads()), 2) | trunk()'

      # 1. Search for my* commits in active branches (as in tree) (also include @)
      #    a = ((trunk()::visible_heads()) & my() | @)
      # 2. Get heads of said tree branches
      #    b = heads(a::)
      # 3. Get the whole branch + an ancestor
      #    c = ancestors(trunk()..b, 2)
      # 4. Also include tunk
      #    log = trunk() | c
      #
      # In other words this gives me "all branches which include my commit(s) or the current commit,
      # a bit of context on them, and trunk".
      #
      # *"my" meaning I'm either the author or the commiter
      #
      # This is more helpful than either the default or willhbr.net's one, because it
      # 1. only shows relevant branches (branches with my commits / the current one)
      # 2. but at the same time actually shows me branches when I'm only partially involved
      revsets.log = "trunk() | ancestors(trunk()..heads(((trunk()..visible_heads()) & my() | @)::), 2)";

      aliases = {
        meow = [
          "util"
          "exec"
          "--"
          "fish"
          "-c"
          "jj new -m (curl -s -X MEOW https://mo.rijndael.cc/ --max-filesize 128 | head -n1)"
        ];
        todo = [
          "new"
          "--no-edit"
          "--insert-after"
          "@"
          "-m"
        ];
        e = [ "edit" ];
        s = [ "show" ];
        n = [
          "next"
          "--edit"
        ];
        p = [
          "prev"
          "--edit"
        ];
        tug = [
          "bookmark"
          "move"
          "--from"
          "heads(::@- & bookmarks())"
          "--to"
          "coalesce(@ & ~empty(), @-)"
        ];
        ll = [
          "log"
          "-Tbuiltin_log_compact_full_description"
          "--reversed"
          "--no-pager"
        ];
        catchup = [
          "rebase"
          "-b"
          "bookmarks() & mine() & ~immutable()"
          "-d"
          "trunk()"
          "--skip-emptied"
        ];
      };

      template-aliases = {
        # Compact log template which only shows important info
        log_oneline = ''
          if(root,
            format_root_commit(self),
            label(if(current_working_copy, "working_copy"),
              concat(
                separate(" ",
                  format_short_change_id_with_hidden_and_divergent_info(self),
                  if(empty, label("empty", "(empty)")),
                  if(description,
                    description.first_line(),
                    label(if(empty, "empty"), description_placeholder),
                  ),
                  bookmarks,
                  tags,
                  working_copies,
                  if(git_head, label("git_head", "HEAD")),
                  if(conflict, label("conflict", "conflict")),
                  if(config("ui.show-cryptographic-signatures").as_boolean(),
                    format_short_cryptographic_signature(signature)),
                ) ++ "\n",
              ),
            )
          )
        '';
        log_oneline_with_status_summary = "log_oneline ++ if(self.current_working_copy() && self.diff().files().len() > 0, status_summary)";
        status_summary = "'\n' ++ self.diff().summary() ++ '\n'";
      };

      templates = {
        # TODO: experiment with different symbols, this is stolen from jana (thanks jana <3)
        # log_node = ''
        #   label("node",
        #     coalesce(
        #       if(!self, label("elided", "~")),
        #       if(current_working_copy, label("working_copy", "@")),
        #       if(conflict, label("conflict", "×")),
        #       if(immutable, label("immutable", "*")),
        #       label("normal", "·")
        #     )
        #   )
        # '';

        log = "log_oneline_with_status_summary";
      };

      signing = {
        signing.behavior = "drop";
        backend = "ssh";
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5He7MsZqHaGWw33BzBeIvfO0kF3ibOtRzN7dDW8uAH";
        backends.ssh.program = lib.getExe' pkgs._1password-gui "op-ssh-sign";
        backends.ssh.allowed-signers = "/home/${params.username}/.allowed-signers";
      };

      fsmonitor.backend = "watchman";

      git = {
        # Sign commits only on push, rather than on creation.
        #
        # This is preferrable because otherwise benign commands like `jj log` or
        # `jj st` may cause auth dialogue from 1password.
        sign-on-push = true;
      };
    };
  };
}
