{
  config,
  pkgs,
  ...
}: {
  # builtin program derivations
  programs = {
    # firefox
    firefox.enable = true;
    # steam
    steam = {
      enable = true;
      extraCompatPackages = [pkgs.unstable.proton-ge-bin];
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
    # gpg
    gnupg.agent = {
      enable = true;
      settings = {
        default-cache-ttl = 28800; # 8 hours
        max-cache-ttl = 28800; # 8 hours
      };
    };
    # neovim
    neovim = {
      enable = true;
      defaultEditor = true;
      # configure = {
      #  packages.myVimPackage = with pkgs.vimPlugins; {
      #    start = [gruvbox-nvim];
      #  };
      # };
    };
    # direnv
    direnv.enable = true;
    # yet-another-nix-helper (nh)
    nh = {
      enable = true;
      # clean = {
      #   enable = true;
      #   extraArgs = "--keep-since 4d --keep 3";
      # };
    };
  };
}
