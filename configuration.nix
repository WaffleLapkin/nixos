# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, lib, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.nixos-hardware.nixosModules.asus-battery
      inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
      inputs.nixos-hardware.nixosModules.common-gpu-nvidia
      inputs.nixos-hardware.nixosModules.common-pc-laptop
      inputs.nixos-hardware.nixosModules.common-pc-laptop-acpi_call
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true; # we want drivers lol
  nixpkgs.overlays = [ inputs.fenix.overlays.default ];

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      # disables the watchdogs so that I can actually turn off the laptop normally lol :|
      "nowatchdog"
      "modprobe.blacklist=sp5100_tco,iTCO_wdt,edac_mce_amd"
      # disable psr (which causes amdgpu crashes) (0x18B & ~0x8)
      "amdgpu.dcfeaturemask=0x183"
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
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
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
    dataDir = "/home/wffl/Documents";
    configDir = "/home/wffl/.config/syncthing";
    # FIXME: configure declaratively, once I'm sure I'm not going to leak private stuff this way lol
  };
  # Sound
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };

  programs = {
    fish.enable = true;
    _1password-gui.enable = true;

    steam = {
      enable = true;
      #remotePlay.openFirewall = true;
      #dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      package = pkgs.steam.override {
        extraPkgs = pkgs: with pkgs; [
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
    htop
    git
    micro
    asusctl
  ];


  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };
  # Enable CUPS to print documents.
  # services.printing.enable = true;
  # Define a user account. Don't forget to set a password with passwd
  users.users.wffl = {
    isNormalUser = true;
    shell = pkgs.fish;
    description = "waffle <wffl@riseup.net>";
    extraGroups = [
      # Enable sudo for the user.
      "wheel"
      # Allow configuring network stuff (this might be unnecessary)
      "networkmanager"
    ];
    packages = with pkgs; [
      firefox
      tree
      thunderbird
      telegram-desktop
      discord
      zulip
      mangohud
      mpv
      zoxide
      obsidian
      zoom-us
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          ms-vscode-remote.remote-ssh
          #a5huynh.vscode-ron
          #alefragnani.bookmarks
          #attilabuti.brainfuck-syntax
          #coalaura.ctrl-s
          #dhall.dhall-lang
          #dhall.vscode-dhall-lsp-server
          eamodio.gitlens
          gruntfuggly.todo-tree
          #haskell.haskell
          #huytd.tokyo-city
          #james-yu.latex-workshop
          #justusadam.language-haskell
          k--kato.intellij-idea-keybindings
          kahole.magit
          #kshetline.ligatures-limited
          #mechatroner.rainbow-csv
          #ms-vscode.cpptools
          ms-vsliveshare.vsliveshare
          #ritwickdey.liveserver
          rust-lang.rust-analyzer
          serayuzgur.crates
          streetsidesoftware.code-spell-checker
          #streetsidesoftware.code-spell-checker-dutch
          #streetsidesoftware.code-spell-checker-russian
          #tabnine.tabnine-vscode
          tamasfe.even-better-toml
          #tht13.html-preview-vscode
          usernamehw.errorlens
          #wakatime.vscode-wakatime
          #wcrichton.flowistry
          #znck.grammarly
        ]; #++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [ #leonardssh.vscord, macabeus.vscode-fluent, matklad.pale-fire, ms-vscode-remote.remote-ssh-edit, ms-vscode.remote-explorer)
        #{
        #  name = "remote-ssh-edit";
        #  publisher = "ms-vscode-remote";
        #  version = "0.47.2";
        #  sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
        #}
        #];
      })
      (fenix.complete.withComponents [
        "rustc"
        "cargo"
        "rustfmt"
        "rust-src"
        "rust-analyzer"
        "clippy"
        "miri"
      ])
    ];
  };

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
