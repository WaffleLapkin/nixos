{ pkgs, ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;

      format = ": $directory\${custom.jj}$sudo$status; ";

      sudo = {
        disabled = false;
      };

      directory = {
        style = "fg:green";
      };

      status = {
        pipestatus = true;
        style = "fg:red";
        format = " [\\[$common_meaning$signal_name$maybe_int\\]]($style)";
        disabled = false;
      };

      custom.jj = {
        format = "$output";
        command = "${pkgs.callPackage ../custom-pkgs/jj-prompty/package.nix { }}/bin/jj-prompty";
        when = "jj root --quiet";
      };
    };
  };
}
