{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./overlays.nix
    "${(import ./npins).custom-nixos-hardware}/lenovo/legion/15arh05h/default.nix"
    ./hardware-configuration.nix
    ./pinning.nix
    ./packages.nix
    ./builtin-programs.nix
    ./builtin-services.nix
    ./services.nix
    ./shell-config.nix
    ./nix-alien.nix
    ./plymouth.nix
  ];

  # services.kea = {
  #   dhcp6 = {
  #     enable = true;
  #     settings = {
  #       interfaces-config = {
  #         interfaces = [
  #           "eno1"
  #         ];
  #         service-sockets-max-retries = 200000;
  #         service-sockets-retry-wait-time = 5000;
  #       };
  #       lease-database = {
  #         name = "/var/lib/kea/dhcp6.leases";
  #         persist = true;
  #         type = "memfile";
  #       };
  #       preferred-lifetime = 3000;
  #       rebind-timer = 2000;
  #       renew-timer = 1000;
  #       subnet6 = [
  #         {
  #           id = 1;
  #           pools = [
  #             {
  #               pool = "2001:db8:1::1-2001:db8:1::ffff";
  #             }
  #           ];
  #           subnet = "2001:db8:1::/64";
  #         }
  #       ];
  #       valid-lifetime = 4000;
  #     };
  #   };
  # };

  virtualisation.docker = {
    enable = true;
  };

  # extra nix settings
  nix = {
    settings = {
      trusted-users = [
        "root"
        "julia"
      ];
      cores = 8;
      log-format = "multiline-with-logs";
    };
    package = pkgs.lixPackageSets.latest.lix;
  };

  # Show package version changes on switch
  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      if [[ -e /run/current-system ]]; then
        echo "--- diff to current-system"
        ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig"
        echo "---"
      fi
    '';
  };

  # mdns enable, Note that “files” is always prepended, and “dns” and “myhostname” are always appended.
  system.nssDatabases.hosts = [
    "mdns4_minimal"
    "[NOTFOUND=return]"
  ];

  # disable broken sleep
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

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
    # kernelPackages = pkgs.linuxPackages_latest;
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
      "docker"
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
