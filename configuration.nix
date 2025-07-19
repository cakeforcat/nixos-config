{ config, pkgs, ... }:

{
  imports =
    [
      <nixos-hardware/lenovo/legion/15arh05h>
      ./hardware-configuration.nix
    ];


  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import <unstable> {
        config = config.nixpkgs.config;
      };
    };
    # Allow unfree packages
    allowUnfree = true;
  };


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
    extraModulePackages = with config.boot.kernelPackages; [ lenovo-legion-module ];
    kernelModules = [
      "ntsync"
      "lenovo-legion-module"
    ];
  };


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
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };


  # global env variables
  environment.variables = {
    EDITOR = "nvim";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  lenovo-legion # remember the kernel module !
  git-credential-oauth
  vpnc
  wget
  turtle
  devenv
  hyfetch
  fastfetch
  ghostty
  fish
  bottom
  hunt
  ripgrep
  fastfetch
  python314
  uv
  (vscode-with-extensions.override {
    vscode = vscodium;
    vscodeExtensions = with pkgs.vscode-extensions; [
      ms-python.python
      ms-python.debugpy
      charliermarsh.ruff
      github.copilot
      github.copilot-chat
      grapecity.gc-excelviewer
      bbenoist.nix
      ms-python.vscode-pylance
      ];
  })
  bitwarden-desktop
  gnome-browser-connector
  wl-clipboard
  protonup-qt
  nvtopPackages.full
  discord
  jellyfin
  jellyfin-web
  jellyfin-ffmpeg
  qbittorrent
  smile
  starship
  fragments
  kicad
  prismlauncher
  mangohud
  mangojuice
  google-chrome

  libreoffice-fresh
  hunspell
  hunspellDicts.en_GB-ise
  hunspellDicts.pl_PL

  gnome-tweaks
  adw-gtk3
  gnomeExtensions.wallpaper-slideshow
  gnomeExtensions.just-perfection
  gnomeExtensions.clipboard-indicator
  gnomeExtensions.fullscreen-avoider
  gnomeExtensions.vitals
  gnomeExtensions.removable-drive-menu
  gnomeExtensions.appindicator
  gnomeExtensions.gsconnect
  gnomeExtensions.power-profile-indicator-2
  gnomeExtensions.smile-complementary-extension

  unstable.mission-center
  ];
  
  security.rtkit.enable = true;
  # builtin services derivations
  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      # Enable the GNOME Desktop Environment.
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      # Configure keymap in X11
      xkb = {
        layout = "pl";
        variant = "";
      };
    };

    # Enable CUPS to print documents.
    # printing.enable = true;
    
    # Enable sound with pipewire.
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # tray icons
    udev.packages = [ pkgs.gnome-settings-daemon ];
    # flatpak for the odd ones out
    flatpak.enable = true;
    # jellyfin
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };

  # builtin program derivations
  programs = {
    # firefox
    firefox.enable = true;
    # steam
    steam = {
      enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
    # GSConnect
    kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect; 
    };
    # git and github
    git = {
      enable = true;
      package = pkgs.gitFull;
    };
    gnupg.agent.enable = true;
    # neovim
    neovim = {
      enable = true;
      defaultEditor = true;
      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [ gruvbox-nvim ];
        };
      };
    };
    # direnv
    direnv.enable = true;
    # shell config
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting
        starship init fish | source
      '';
      shellAliases = {
        econf = "EDITOR=nvim sudo -e /etc/nixos/configuration.nix";
        ehwconf = "EDITOR=nvim sudo -e /etc/nixos/hardware-configuration.nix";
        nixit = "sudo nixos-rebuild switch";
        nix-fish = "nix-shell --command fish";
      };
    };
    starship = {
      enable = true;
      settings = {
        format = "[](#9A348E)$username[](bg:#DA627D fg:#9A348E)$directory[](fg:#DA627D bg:#FCA17D)$git_branch$git_status[](fg:#FCA17D bg:#86BBD8)$c$elixir$elm$golang$gradle$haskell$java$julia$nodejs$nim$rust$scala[](fg:#86BBD8 bg:#06969A)$docker_context[](fg:#06969A bg:#33658A)$time[ ](fg:#33658A)$nix_shell";
        username = {
          show_always = true;
          style_user = "bg:#9A348E";
          style_root = "bg:#9A348E";
          format = "[$user ]($style)";
          disabled = false;
        };
        directory = {
          style = "bg:#DA627D";
          format = "[ $path ]($style)";
          truncation_length = 4;
          truncation_symbol = "…/";
        };
        directory.substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = " ";
          "Pictures" = " ";
        };
        c = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        cpp = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        docker_context = {
          symbol = " ";
          style = "bg:#06969A";
          format = "[ $symbol $context ]($style)";
        };
        elixir = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        elm = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        git_branch = {
          symbol = "";
          style = "bg:#FCA17D";
          format = "[ $symbol $branch ]($style)";
        };
        git_status = {
          style = "bg:#FCA17D";
          format = "[$all_status$ahead_behind ]($style)";
        };
        golang = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        gradle = {
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        haskell = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        java = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        julia = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        nodejs = {
          symbol = "";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        nim = {
          symbol = "󰆥 ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        rust = {
          symbol = "";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        scala = {
          symbol = " ";
          style = "bg:#86BBD8";
          format = "[ $symbol ($version) ]($style)";
        };
        time = {
          disabled = false;
          time_format = "%R"; # Hour:Minute Format
          style = "bg:#33658A";
          format = "[ ♥ $time ]($style)";
        };
        nix_shell = {
          disabled = false;
          symbol = " ";
          style = "bg:#33658A";
          format = "[](fg:#33658A)[$symbol]($style)[ ](fg:#33658A)";
        };
      };
    };
  };


  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
