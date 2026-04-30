{
  config,
  pkgs,
  ...
}:
{
  security.rtkit.enable = true;
  # builtin services derivations
  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;
      # Configure keymap in X11
      xkb = {
        layout = "pl";
        variant = "";
      };
    };

    # Enable the GNOME Desktop Environment.
    displayManager = {
      gdm.enable = true;
      #autoLogin.user = "julia";
    };
    desktopManager.gnome.enable = true;

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
    # fwupd
    # fwupd.enable = true;
    # tailscale
    tailscale.enable = true;
    # auto timezone
    # ugh borked for now
    # automatic-timezoned.enable = true;
    # geoclue2.geoProviderUrl = "https://api.beacondb.net/v1/geolocate";

    #testing ds4u
    udev.extraRules = ''
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0664", GROUP="input", TAG+="uaccess"
      SUBSYSTEM=="hidraw", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0df2", MODE="0664", GROUP="input", TAG+="uaccess"
    '';
  };
  # dont start jellyfin on boot
  systemd.services.jellyfin.wantedBy = pkgs.lib.mkForce [ ];
}
