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
        # without this logging in directly with fish on a non-nixos machine doesn't work :/
        if test -e /etc/profile.d/nix-daemon.fish
          source /etc/profile.d/nix-daemon.fish
        end

        ${config.programs.jujutsu.package}/bin/jj util completion fish | source
        fish_add_path "$HOME/.cargo/bin"
      '';
    };
  };
}
