{
  lib,
  stdenvNoCC,
  requireFile,
  callPackage,
  makeBinaryWrapper,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  icoutils,
  gcc,
  libgcc,
  icu,
  libx11,
  libxcursor,
  libxinerama,
  libxi,
  libxrandr,
  libGL,
  libglvnd,
  libxkbcommon,
  wayland,
  alsa-lib,
  vulkan-loader,
  vulkan-validation-layers,
  libpulseaudio,
  dotnet-runtime_10,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  version = "2026.8.5.5168"; # Bump to update
  pname = "ksa";

  src = requireFile {
    name = "setup_ksa_v${finalAttrs.version}.tar.gz";
    url = "https://ahwoo.com/app/100000/kitten-space-agency";
    sha256 = "17f1hw13wqpszx3y3cp0qy4fii60jg9z3vn93h0bgbvsfs0h7305";
  };

  icoSrc = requireFile {
    name = "ksa_ico.ico";
    url = "https://forums.ahwoo.com/threads/ksa-icon-and-flat-logo-cc-4-0.496/";
    sha256 = "1mjzlin2mhd05n7bbc80i7miijn9b0n06d7c1w8k9247xzs5bc3b";
  };

  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeBinaryWrapper
    copyDesktopItems
    icoutils
  ];

  buildInputs = [
    libgcc
    icu
    wayland
    libx11
    libxcursor
    libxinerama
    libxi
    libxrandr
    libGL
    libglvnd
    libxkbcommon
    alsa-lib
    vulkan-loader
    vulkan-validation-layers
    libpulseaudio
    dotnet-runtime_10
  ];

  appendRunpaths = [ (lib.makeLibraryPath finalAttrs.buildInputs) ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/ksa
    cp -a * $out/share/ksa
    chmod +x $out/share/ksa/KSA
    chmod +x $out/share/ksa/Brutal.Monitor.Subprocess

    makeBinaryWrapper "$out/share/ksa/KSA" "$out/bin/KSA" \
      --unset WAYLAND_DISPLAY \
      --unset WAYLAND_SOCKET \
      --set XDG_SESSION_TYPE "x11" \
      --prefix VK_LAYER_PATH : "${vulkan-validation-layers}/share/vulkan/explicit_layer.d" \
      --prefix PATH : "${dotnet-runtime_10}" \
      --set DOTNET_ROOT "${dotnet-runtime_10}/share/dotnet" \
      --set DOTNET_ROOT_X64 "${dotnet-runtime_10}/share/dotnet" \
      --chdir $out/share/ksa

    # Install icon files
    mkdir -pv $out/share/icons/hicolor/256x256/apps/
    icotool -x $icoSrc
    cp *_256x256x32.png $out/share/icons/hicolor/256x256/apps/ksa.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "KSA";
      desktopName = "KSA";
      icon = "ksa";
      comment = finalAttrs.meta.description;
      exec = "KSA";
      terminal = false;
      type = "Application";
      categories = [
        "Game"
      ];
      keywords = [
        "Kitten"
        "Space"
        "Agency"
        "Kerbal"
      ];
    })
  ];

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    homepage = "https://ksa.ahwoo.com";
    description = "Mission to create the spaceflight game that inspires the next generation of space explorers";
    #changelog = ""; # Space intentionally left blank, at the moment of writing, changelogs are only published in the game's discord
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "KSA";
    maintainers = with lib.maintainers; [
      leha44581
      maevii
    ];
  };
})
