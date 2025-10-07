{ ... }:
{
  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    # Set the top-level options that are available
    matchBlocks = {
      "*" = {
        forwardAgent = true;
        identityAgent = "~/.1password/agent.sock";
      };

      "pineapple.computer" = {
        port = 69;
      };

      "arch-vps" = {
        user = "waffle";
      };
      "archbook" = {
        user = "waffle";
      };

      "dev-desktop-1" = {
        user = "gh-WaffleLapkin";
        hostname = "dev-desktop-eu-1.infra.rust-lang.org";
        # Force ipv4 (ipv6 doesn't work for some reason lol)
        addressFamily = "inet";
      };
      "dev-desktop-2" = {
        user = "gh-WaffleLapkin";
        hostname = "dev-desktop-eu-2.infra.rust-lang.org";
        # Force ipv4 (ipv6 doesn't work for some reason lol)
        addressFamily = "inet";
      };
    };
  };
}
