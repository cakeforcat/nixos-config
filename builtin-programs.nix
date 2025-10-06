{
  config,
  pkgs,
  ...
}:
{
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
      config = {
        credential.helper = [
          "cache --timeout 21600" # 6 hours
          "oauth"
        ];
        init.defaultBranch = "main";
        pull.rebase = true;
        user = {
          email = "cakeforcat@gmail.com";
          name = "cakeforcat";
          signingkey = "0693518A0F875C13";
        };
        commit.gpgsign = true;
      };
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
    # appimage
    appimage = {
      enable = true;
      binfmt = true;
      package = pkgs.appimage-run.override {
        extraPkgs =
          pkgs: with pkgs; [
            webkitgtk_4_1
          ];
      };
    };
    # nix-ld
    nix-ld.enable = true;
  };
}
