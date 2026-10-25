{
  config,
  pkgs,
  ...
}:
{
  nixpkgs.overlays = [

    # (final: prev: {
    #   pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    #     (python-final: python-prev: {
    #       mpv = python-prev.mpv.overridePythonAttrs (oldAttrs: {
    #         disabledTests = [ "RegressionTests::test_wait_for_property_concurrency" ];
    #       });
    #     })
    #   ];
    # })

    # (final: _prev: {
    #   pnpm_10_29_2 = final.pnpm_10;
    # })

    # (final: prev: {
    #   vulkan-validation-layers = prev.vulkan-validation-layers.overrideAttrs (old: {
    #     cmakeFlags = [
    #       "-DUPDATE_DEPS=OFF"
    #     ]
    #     ++ old.cmakeFlags;
    #   });
    # })

    (final: prev: {
      linuxPackages = prev.linuxPackages.extend (
        final': prev': {
          lenovo-legion-module = prev'.lenovo-legion-module.overrideAttrs (old: {
            makeFlags = old.makeFlags ++ [
              "INSTALL_MOD_PATH=${placeholder "out"}"
              "DEPMOD=true"
            ];
            installTargets = [ "modules_install" ];
            installFlags = [
              "-C"
              "${prev'.kernel.dev}/lib/modules/${prev'.kernel.modDirVersion}/build"
              "M=$(PWD)"
            ];
          });
        }
      );
    })

  ];
}
