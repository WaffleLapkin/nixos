{
  inputs,
  pkgs,
  params,
  hostname,
  lib,
  ...
}:
{
  imports = [
    ./locale.nix
    ./friends.nix
    ./gamer.nix
    ./steno.nix
  ];

  nix.settings.warn-dirty = false;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.systemd-boot.memtest86.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking.hostName = hostname; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  systemd.services.NetworkManager-wait-online.enable = false; # workaround for a bug <https://github.com/NixOS/nixpkgs/issues/180175>

  hardware = {
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  services.tailscale.enable = true;
  services.openssh.enable = true;
  services.syncthing = {
    enable = true;
    user = params.username;
    dataDir = "/home/${params.username}/documents";
    configDir = "/home/${params.username}/.config/syncthing";
    # FIXME: configure declaratively, once I'm sure I'm not going to leak private stuff this way lol
  };
  # Sound
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber.enable = true; # https://discord.com/channels/1038201022000156772/1168383071796613250/1241400869132701828
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };

  # Provide debuginfo to gdb for nix-installed packages.
  services.nixseparatedebuginfod2.enable = true;

  users = {
    defaultUserShell = pkgs.fish;
    users.${params.username} = {
      isNormalUser = true;
      description = params.name;
      extraGroups = [
        # Enable sudo for the user.
        "wheel"
        # Allow configuring network stuff (this might be unnecessary)
        "networkmanager"
        # To be able to interact with probes
        "plugdev"
        # shark :3
        "wireshark"
      ];
      packages = [ ];
    };
  };

  environment.variables.EDITOR = "hx"; # FIXME: use home-manager instead, for per-user config
  environment.etc = {
    "xdg/user-dirs.defaults".text = ''
      PICTURES=pictures
      MUSIC=music
      VIDEOS=videos
      DOCUMENTS=documents
      DOWNLOAD=download
      DESKTOP=desktop
      TEMPLATES=templates
      PUBLICSHARE=public
    '';
  };
  # https://github.com/NixOS/nixpkgs/issues/63489#issuecomment-1482312887
  # Baloo is kinda annoying and indexing everything with no end, so yeah :/
  environment.etc."xdg/baloofilerc".source = (pkgs.formats.ini { }).generate "baloorc" {
    "Basic Settings" = {
      "Indexing-Enabled" = false;
    };
  };

  programs = {
    fish.enable = true;

    _1password.enable = true;
    _1password-gui = {
      enable = true;
      # this makes system auth etc. work properly
      polkitPolicyOwners = [ params.username ];
    };

    direnv = {
      enable = true; # this conflicts with lix for some reason?...
      nix-direnv.package = pkgs.lixPackageSets.stable.nix-direnv;
    };

    wireshark.enable = true;
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "1password"
      "1password-cli"
      "zoom"
      "google-chrome"
      "obsidian"
      "steam"
      "steam-unwrapped"
      "discord"
    ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # The grouping is extremely arbitrary and potentially useless,
    # but I hate it less when they are groupped so here we go.

    # CLI
    alacritty
    kitty
    htop
    ripgrep
    (callPackage ../custom-pkgs/usbutils/package.nix { })
    age
    jq
    atuin
    bat
    tree
    zoxide
    fzf
    magic-wormhole
    presenterm

    # text editing
    inputs.helix.packages.${pkgs.system}.default
    zed-editor

    # nix
    comma
    nix-output-monitor
    nil # nix language server

    # VCS
    git
    jujutsu
    delta

    # compilation & language support
    meld
    tinymist # typst language server

    # social
    signal-desktop
    telegram-desktop
    zulip
    zoom-us
    # Discord client with working screen sharing under wayland/plasma.
    # (I was told in sway the default client works too)
    # (this could get me banned but ugh)
    # (discord proper now can also do that, but eeeegh)
    # vesktop
    discord

    # multimedia
    emulsion
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
      ];
    })
    mpv
    wl-clipboard-rs # used by an MPV script I have which allows pasting URLs into mpv
    # aseprite # broken currently...
    krita
    # davinci-resolve
    ffmpeg-full
    helvum # allows configuring sound stuff patchbay style

    # Makes screen share through FF work.
    # This should *not* be required, because plasma should enable it itself,
    # but apperently this actually makes a difference somehow...
    kdePackages.xdg-desktop-portal-kde

    # etc
    typst
    yubikey-manager
    ydotool
    google-chrome
    firefox
    thunderbird
    obsidian
    comic-mono
    transmission_4-qt
    kando
  ];

  fonts.packages = with pkgs; [
    sarasa-gothic
    libertinus
    iosevka
    atkinson-hyperlegible-next
    atkinson-hyperlegible-mono
    monocraft
    raleway
  ];

  # Create a "plugdev" group.
  # Required for `pkgs.picoprobe-udev-rules` to properly work.
  users.groups.plugdev = { };
  users.groups.wireshark = { };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.picoprobe-udev-rules ];
  services.udev.extraRules = ''
    # A Crude hack in order to make all hidraws accessible to me.
    # plover-hid needs this to work.
    # ideally I'd select only the plover-hid compatible devices,
    # but I don't think udev rules can select devices based on descriptors so rip.
    KERNEL=="hidraw*" SUBSYSTEM=="hidraw" MODE="0660", GROUP="plugdev", TAG+="uaccess"

    # https://discourse.nixos.org/t/using-wireshark-as-an-unprivileged-user-to-analyze-usb-traffic/38011
    SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"
  '';
  services.udev.extraHwdb = ''
    # Rebinds keys on elecom huge trackball
    #
    # tip: You can use `sudo evtest` to get the key values and stuff.
    #
    # 90001 = L
    # 90002 = R
    # 90003 = M (scroll wheel button)
    # 90004 = < (back)
    # 90005 = > (forward)
    # 90006 = Fn1
    # 90007 = Fn2
    # 90008 = Fn3
    #
    # key_blue -- noop
    # btn_0 -- corresponds to key code 256. idk what it does,
    #          but we can make kwin see it as "scroll" button
    #          (sadly kwin only wants btn_*, key_* won't work...)
    evdev:input:b0003v056Ep010D*
      KEYBOARD_KEY_90001=key_blue
      KEYBOARD_KEY_90002=btn_0
      KEYBOARD_KEY_90003=key_blue
      KEYBOARD_KEY_90004=btn_middle
      KEYBOARD_KEY_90005=key_blue
      KEYBOARD_KEY_90006=btn_left
      KEYBOARD_KEY_90007=btn_right
      KEYBOARD_KEY_90008=key_esc
  '';
}
