{
  config,
  pkgs,
  ...
}: let
  sources = import ./npins;
in {
  # kill channels
  nix = {
    channel.enable = false;
    nixPath = [
      "nixpkgs=/etc/nixos/nixpkgs"
      "nixos-config=/home/julia/nixos-config/configuration.nix"
    ];
  };
  environment.etc = {
    "nixos/nixpkgs".source = builtins.storePath pkgs.path;
  };

  # pinning
  nixpkgs = {
    config = {
      packageOverrides = pkgs: {
        unstable = import sources.nixpkgs-unstable {config = config.nixpkgs.config;};
        vpncpin = import sources.nixpkgs-vpncpin {config = config.nixpkgs.config;};
      };
    };
  };
}
