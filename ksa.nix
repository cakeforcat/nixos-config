{
  lib,
  stdenvNoCC,
  requireFile,
  callPackage,
  makeBinaryWrapper,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
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
  version = "2026.7.4.4860"; # Bump to update
  pname = "ksa";
  src = requireFile {
    name = "setup_ksa_v${finalAttrs.version}.tar.gz";
    url = "https://ahwoo.com/app/100000/kitten-space-agency";
    sha256 = "1vxzcwvlms4d6hhf2jb7cma1wns5vsa968zq492xi2kzkc75qpdj";
  };

  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeBinaryWrapper
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

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "ksa";
      desktopName = "KSA";
      comment = finalAttrs.meta.description;
      exec = "ksa";
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
