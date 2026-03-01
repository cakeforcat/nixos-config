{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./nixos-hardware/lenovo/legion/15arh05h/default.nix
    ./hardware-configuration.nix
    ./pinning.nix
    ./packages.nix
    ./builtin-programs.nix
    ./builtin-services.nix
    ./shell-config.nix
    ./vm.nix
    ./nix-alien.nix
    ./plymouth.nix
  ];

  # extra nix settings
  nix.settings.trusted-users = [
    "root"
    "julia"
  ];
  # system.rebuild.enableNg = true; enabled by default in nixos 25.11
  # system.nixos-init.enable = true;
  nix.settings.cores = 8;

  # fix for broken build on stable
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  # Apply CachyOS kernel 6.19 patch to NVIDIA latest driver
  # hardware.nvidia.package =
  #   let
  #     base = config.boot.kernelPackages.nvidiaPackages.latest;
  #     cachyos-nvidia-patch = pkgs.fetchpatch {
  #       url = "https://raw.githubusercontent.com/CachyOS/CachyOS-PKGBUILDS/master/nvidia/nvidia-utils/kernel-6.19.patch";
  #       sha256 = "sha256-YuJjSUXE6jYSuZySYGnWSNG5sfVei7vvxDcHx3K+IN4=";
  #     };
  #     # Patch the appropriate driver based on config.hardware.nvidia.open
  #     driverAttr = if config.hardware.nvidia.open then "open" else "bin";
  #   in
  #   base
  #   // {
  #     ${driverAttr} = base.${driverAttr}.overrideAttrs (oldAttrs: {
  #       patches = (oldAttrs.patches or [ ]) ++ [ cachyos-nvidia-patch ];
  #     });
  #   };

  # lix
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     inherit
  #       (prev.lixPackageSets.git)
  #       nixpkgs-review
  #       nix-eval-jobs
  #       nix-fast-build
  #       colmena
  #       ;
  #   })
  # ];
  nix.package = pkgs.lixPackageSets.latest.lix;

  # mdns enable, Note that “files” is always prepended, and “dns” and “myhostname” are always appended.
  system.nssDatabases.hosts = [
    "mdns4_minimal"
    "[NOTFOUND=return]"
  ];

  # disable broken sleep
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # systemd.slices.anti-hungry.sliceConfig = {
  #   CPUAccounting = true;
  #   MemoryAccounting = true;
  #   CPUQuota = "50%";
  #   MemoryHigh = "7G";
  #   MemoryMax = "8G";
  #   MemorySwapMax = "10G";
  #   MemoryZSwapMax = "10G";
  # };
  # systemd.services.nix-daemon.serviceConfig.Slice = "anti-hungry.slice";
  # systemd.services.nixos-upgrade.serviceConfig.Slice = "anti-hungry.slice";

  # RTL-SDR
  hardware.rtl-sdr.enable = true;

  # Boot
  boot = {
    # Bootloader
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # Kernel
    kernelPackages = pkgs.linuxPackages_latest;
    # Kernel modules
    kernelModules = [
      "ntsync"
    ];
  };

  # Networking
  networking = {
    hostName = "Laptopiszcze"; # Define your hostname.
    # Enable networking
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-vpnc
        networkmanager-openvpn
      ];
    };
    firewall.checkReversePath = false;
  };

  # Set your time zone.
  # now dynamic using automatic-timezoned
  # ok timezoned is borked rn, lets go to gnome
  #time.timeZone = "Europe/London";
  time.timeZone = lib.mkForce null;

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.julia = {
    isNormalUser = true;
    description = "Julia";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "plugdev"
      "dialout"
      "gamemode"
    ];
    # packages = with pkgs; [
    #   thunderbird
    # ];
  };

  # global env variables
  environment.variables = {
    EDITOR = "nvim";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
