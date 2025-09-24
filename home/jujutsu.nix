{
  lib,
  config,
  pkgs,
  pkgs-unstable,
  params,
  ...
}:
let
  jj = lib.getExe config.programs.jujutsu.package;

  aliasBashExec = command: [
    "util"
    "exec"
    "--"
    (lib.getExe pkgs.bash)
    "-c"
    command
  ];
in
{
  programs.jujutsu = {
    enable = true;
    package = pkgs-unstable.jujutsu;
    settings = {
      user.email = "Waffle Lapkin";
      user.name = "waffle.lapkin@gmail.com";

      ui.default-command = [
        "log"
        "--reversed"
        "--no-pager"
      ];
      ui.diff-editor = ":builtin";

      ui.pager = "delta";
      ui.diff-formatter = ":git"; # for delta

      templates.git_push_bookmark = "\"ea-\" ++ change_id.short()"; # meow?

      revset-aliases = {
        "my()" = "user(\"waffle.lapkin@gmail.com\")";
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
          "heads(@-::@ & ~empty())"
        ];
      };

      signing = {
        signing.behavior = "drop";
        backend = "ssh";
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5He7MsZqHaGWw33BzBeIvfO0kF3ibOtRzN7dDW8uAH";
        backends.ssh.program = "/run/current-system/sw/bin/op-ssh-sign";
        backends.ssh.allowed-signers = "/home/${params.username}/.allowed-signers";
      };

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
