{
  config,
  pkgs,
  ...
}:
{
  # allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    # permittedInsecurePackages = ["googleearth-pro-7.3.6.10201"];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    npins
    lenovo-legion # remember the kernel module !
    git-credential-oauth
    vpnc
    wget
    # turtle # broken rn
    gitui
    devenv
    hyfetch
    fastfetch
    ghostty
    fish
    bottom
    hunt
    fd
    ripgrep
    fastfetch
    # fish-lsp
    wlink
    gnome-firmware
    # freecad
    celluloid
    spotify
    pbpctrl
    gqrx
    #orca-slicer
    arduino-ide
    #sdrangel
    #googleearth-pro

    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions =
        with pkgs.vscode-extensions;
        [
          jnoortheen.nix-ide
          ms-python.python
          ms-python.debugpy
          charliermarsh.ruff
          github.copilot
          github.copilot-chat
          grapecity.gc-excelviewer
          emroussel.atomize-atom-one-dark-theme
          ms-python.vscode-pylance
          myriad-dreamin.tinymist
          mkhl.direnv
          tamasfe.even-better-toml
          ndonfris.fish-lsp
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "openscad-language-support";
            publisher = "Leathong";
            version = "2.0.1";
            sha256 = "sha256-GTvn97POOVmie7mOD/Q3ivEHXmqb+hvgiic9pTWYS0s=";
          }
        ];
    })
    bitwarden-desktop
    wl-clipboard
    nvtopPackages.full
    warp
    discord
    fractal

    jellyfin
    jellyfin-web
    jellyfin-ffmpeg

    qbittorrent
    smile
    starship
    kicad
    prismlauncher
    zulu25
    mangohud
    mangojuice

    nixfmt
    libnotify
    jq
    nil

    nix-du
    graphviz

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
    gnomeExtensions.touchpad-gesture-customization
    gnomeExtensions.bluetooth-battery-meter
    gnomeExtensions.open-bar
    gnomeExtensions.fuzzy-app-search
    gnomeExtensions.color-picker
    gnomeExtensions.caffeine
    #cynthion
    packetry

    openscad-unstable
    # ungoogled-chromium
    mommy
    heroic
    diebahn
    #unstable.mission-center
    #bambu-studio
    (gnuradio.override {
      extraPackages = with gnuradioPackages; [
        lora_sdr
      ];
    })
  ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-console
    totem
    showtime
  ];
}
