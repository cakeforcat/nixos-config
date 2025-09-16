{
  config,
  pkgs,
  ...
}: {
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
    fish-lsp
    wlink
    gnome-firmware
    freecad
    celluloid
    spotify
    pbpctrl
    #googleearth-pro

    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with pkgs.vscode-extensions;
        [
          ms-python.python
          ms-python.debugpy
          charliermarsh.ruff
          github.copilot
          github.copilot-chat
          grapecity.gc-excelviewer
          bbenoist.nix
          jeff-hykin.better-nix-syntax
          emroussel.atomize-atom-one-dark-theme
          ms-python.vscode-pylance
          myriad-dreamin.tinymist
          mkhl.direnv
          tamasfe.even-better-toml
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "fish-lsp";
            publisher = "ndonfris";
            version = "0.1.13";
            sha256 = "sha256-jPBcSQHuSvvWfc4KdtTkUJkx/fGYiAANFjABe4DzopQ=";
          }
        ];
    })
    bitwarden-desktop
    gnome-browser-connector
    wl-clipboard
    # protonup-qt
    nvtopPackages.full
    warp
    #vesktop
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
    zulu24
    mangohud
    mangojuice

    alejandra
    libnotify
    jq

    nix-du
    graphviz

    libreoffice-fresh
    hunspell
    hunspellDicts.en_GB-ise
    hunspellDicts.pl_PL

    #ulauncher
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
    cynthion
    packetry

    #unstable.mission-center
    #bambu-studio
  ];

  environment.gnome.excludePackages = with pkgs; [
    gnome-console
    totem
  ];
}
