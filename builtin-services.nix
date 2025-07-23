{
  config,
  pkgs,
  ...
}: {
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
    udev.packages = [pkgs.gnome-settings-daemon];
    # flatpak for the odd ones out
    flatpak.enable = true;
    # jellyfin
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
    # fwupd
    fwupd.enable = true;
  };
}
