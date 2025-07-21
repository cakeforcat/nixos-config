{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./nixos-hardware/lenovo/legion/15arh05h/default.nix
    ./hardware-configuration.nix
    ./packages.nix
    ./builtin-programs.nix
    ./builtin-services.nix
    ./shell.nix
  ];

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
    extraModulePackages = with config.boot.kernelPackages; [lenovo-legion-module];
    kernelModules = [
      "ntsync"
      "lenovo-legion-module"
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
      ];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

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
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      #  thunderbird
    ];
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
