{
  config,
  pkgs,
  ...
}: {
  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import <unstable> {
        config = config.nixpkgs.config;
      };
    };
    # Allow unfree packages
    allowUnfree = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
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
    ripgrep
    fastfetch
    python314
    uv
    fish-lsp
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
          ms-python.vscode-pylance
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "fish-lsp";
            publisher = "ndonfris";
            version = "0.1.7";
            sha256 = "xEqstBvz9EDd5FMjfY7dynFNw2angDNZcWIr06Uguw4=";
          }
        ];
    })
    bitwarden-desktop
    gnome-browser-connector
    wl-clipboard
    # protonup-qt
    nvtopPackages.full
    warp
    vesktop
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

    alejandra
    libnotify
    jq

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
}
