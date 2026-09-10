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
  ];
}
