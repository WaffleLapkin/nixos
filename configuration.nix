# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.asus-battery
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-nvidia
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true; # we want drivers lol
  nixpkgs.overlays = [ inputs.fenix.overlays.default ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.systemd-boot.memtest86.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      # disables the watchdogs so that I can actually turn off the laptop normally lol :|
      "nowatchdog"
      "modprobe.blacklist=sp5100_tco,iTCO_wdt,edac_mce_amd"
      # disable psr (which causes amdgpu crashes) (0x18B & ~0x8)
      "amdgpu.dcfeaturemask=0x183"
      # Weird hack to fix fucking artifacts.
      # Without it I currently (as of 2024-07-20) get a lot of artifacts when windows are updating.
      # The artifacts are most prevalent when there are multiple windows open and in firefox and steam.
      # This doesn't fix the artifacts fully -- I still get them in the control panel (or whatever
      # it's called) when opening firefox. /But/, it does make it possible for me to use my computer,
      # so a win is a win ig.
      "amdgpu.sg_display=0"
    ];
    initrd.luks.devices.nixos-enc = {
      device = "/dev/nvme0n1p2";
      preLVM = true;
    };
  };
  fileSystems."/boot".options = [ "umask=0077" ];

  networking.hostName = "polaris"; # Define your hostname.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  systemd.services.NetworkManager-wait-online.enable = false; # workaround for a bug <https://github.com/NixOS/nixpkgs/issues/180175>
  time.timeZone = "Europe/Amsterdam";

  ## try to fix visual bugs :sob:
  #chaotic.mesa-git.enable = true;
  #chaotic.mesa-git.method = "replaceRuntimeDependencies";

  hardware = {
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
    nvidia = {
      open = false;
      modesetting.enable = true;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        nvidiaBusId = "PCI:01:0:0";
        amdgpuBusId = "PCI:69:0:0"; # nice
      };
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    sensor.iio.enable = true; # auto rotate screen?
  };

  # In theory this allows me to change asus weird stuff
  # (in practice it doesn't)
  services.asusd = {
    enable = true;
    enableUserService = true;
  };

  # DE
  services.desktopManager.plasma6.enable = true;
  #services.displayManager.sddm.enable = true; # sddm is hella laggy, I'd prefer using gdm (or something else entirely!)
  #services.displayManager.sddm.wayland.enable = true;
  services.xserver = {
    enable = true;
    #desktopManager.gnome.enable = true; # I don't necesserily need gnome and it adds a ton of annoying packages
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = true;
    videoDrivers = [ "nvidia" ];
    #videoDrivers = lib.mkForce [ "modesetting" ];
    xkb.layout = "us,ru";
  };
  #programs.ssh.askPassword = pkgs.lib.mkForce "${pkgs.ksshaskpass.out}/bin/ksshaskpass"; # https://github.com/NixOS/nixpkgs/issues/75867
  #hardware.pulseaudio.enable = false; # gnome-only workaround?
  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # try to run electron apps with ozone so they scale normally
  #environment.sessionVariables.GDK_SCALE = "2"; # try to scale non-native running apps
  environment.sessionVariables.STEAM_FORCE_DESKTOPUI_SCALING = "1.5"; # force steam to scale
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  # Enable the OpenSSH daemon.
  services.tailscale.enable = true;
  services.openssh.enable = true;
  services.syncthing = {
    enable = true;
    user = "wffl";
    dataDir = "/home/wffl/documents";
    configDir = "/home/wffl/.config/syncthing";
    # FIXME: configure declaratively, once I'm sure I'm not going to leak private stuff this way lol
  };
  services.tlp.enable = false;
  services.power-profiles-daemon.enable = true; # conflicts with tlp
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

  programs = {
    fish.enable = true;

    _1password.enable = true;
    _1password-gui = {
      enable = true;
      # this makes system auth etc. work properly
      polkitPolicyOwners = [ "wffl" ];
    };
    direnv.enable = true;
    wireshark.enable = true;

    steam = {
      enable = true;
      #remotePlay.openFirewall = true;
      #dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      package = pkgs.steam.override {
        extraPkgs =
          pkgs: with pkgs; [
            # Needed for gamescope to work
            # <https://www.reddit.com/r/NixOS/comments/1bmj4mz/gamescope_and_steam/>
            # <https://github.com/NixOS/nixpkgs/issues/162562#issuecomment-1229444338>
            libkrb5
            keyutils
          ];
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # The grouping is extremely arbitrary and potentially useless,
    # but I hate it less when they are groupped so here we go.
    
    # CLI
    alacritty
    htop
    ripgrep
    (callPackage ./custom-pkgs/usbutils/package.nix { })
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
    vesktop

    # gaming
    r2modman
    olympus
    wineWowPackages.waylandFull
    mangohud

    # multimedia
    emulsion
    (pkgs.wrapOBS {
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
      ];
    })
    mpv
    wl-clipboard-rs # used by an MPV script I have which allows pasting URLs into mpv
    aseprite
    krita
    # davinci-resolve
    ffmpeg-full
    
    # misc
    asusctl
    # Makes screen share through FF work.
    # This should *not* be required, because plasma should enable it itself,
    # but apperently this actually makes a difference somehow...
    kdePackages.xdg-desktop-portal-kde
    qt5.qtwayland # removes a warning from plover
    (inputs.plover-flake.packages.${system}.plover.withPlugins (
      plugins: with plugins; [
        plover-machine-hid
      ]
    ))
    typst
    yubikey-manager
    ydotool
    google-chrome
    firefox
    thunderbird
    obsidian
    comic-mono
    transmission_4-qt    
  ];

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

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

  users = {
    defaultUserShell = pkgs.fish;
    users.wffl = {
      isNormalUser = true;
      description = "waffle";
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
      packages = [];
    };
  };

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

  # Local snapshots (time machine)
  # <https://github.com/digint/btrbk?tab=readme-ov-file#example-local-regular-snapshots-time-machine>
  # Thttps://github.com/GoldsteinE/nixos/blob/75fa9409534ac5e2a95ec7e5ed6804fe1b2e476e/modules/desktop/btrbk.nix>
  services.btrbk.instances.local.settings = {
    volume."/" = {
      snapshot_dir = "btrbk_snapshots";
      snapshot_preserve_min = "1w";
      snapshot_preserve = "4w";
      subvolume = {
        etc = { };
        home = { };
      };
    };
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;
  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment? No.
}

# idk where to put it, but I expirience this bug: <https://bugs.kde.org/show_bug.cgi?id=459373>
