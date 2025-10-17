{ ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;

      format = ": $directory$sudo$status; ";

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
    };
  };
}
