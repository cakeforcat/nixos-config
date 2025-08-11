{
  config,
  pkgs,
  ...
}: let
  version = "02.02.00.68";

  src = pkgs.fetchurl {
    url = "https://github.com/bambulab/BambuStudio/releases/download/v${version}/Bambu_Studio_ubuntu-24.04_PR-7606.AppImage";
    hash = "sha256-znju2iCLUQHM7fO3fV4HNquqeAOPn7vyQtVQ9w9D/RY=";
  };

  bambu-studio = pkgs.appimageTools.wrapType2 {
    name = "BambuStudio";
    pname = "bambu-studio";
    inherit version;
    appimageContents = pkgs.appimageTools.extract { inherit src; };
    inherit src;
    profile = ''
      export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      export GIO_MODULE_DIR="${pkgs.glib-networking}/lib/gio/modules/"
    '';
    extraPkgs = pkgs: with pkgs; [
      cacert
      curl
      glib
      glib-networking
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      webkitgtk_4_1
      linuxPackages.nvidia_x11
      libglvnd
      fontconfig
      dejavu_fonts
      liberation_ttf
      libxkbcommon
      hack-font
    ];
  };
in {
  environment.systemPackages = [
    bambu-studio
  ];
}