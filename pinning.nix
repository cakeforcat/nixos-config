{
  config,
  pkgs,
  ...
}:
let
  sources = import ./npins;
in
{
  # kill channels
  nix = {
    channel.enable = false;
    nixPath = [
      "nixpkgs=/etc/nixos/nixpkgs"
    ];
  };
  environment.etc = {
    "nixos/nixpkgs".source = builtins.storePath pkgs.path;
  };

  nixpkgs.config.packageOverrides = pkgs: {
    torlinkpin = import sources.torlink-nixpkgs { config = config.nixpkgs.config; };
    openrocketpin = import sources.new-openrocket-nixpkgs { config = config.nixpkgs.config; };
  };
}
