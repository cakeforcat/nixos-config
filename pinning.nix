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
      "nixos-config=/home/julia/nixos-config/configuration.nix"
    ];
  };
  environment.etc = {
    "nixos/nixpkgs".source = builtins.storePath pkgs.path;
  };
  # command-not-found fix
  programs.command-not-found.dbPath = "/etc/nixos/nixpkgs/programs.sqlite";

  # pinning
  nixpkgs.config.packageOverrides = pkgs: {
    vpncpin = import sources.nixpkgs-vpncpin { config = config.nixpkgs.config; };
  };

  # lix
  # imports = [(import "${sources.lix-module}/module.nix" {lix = sources.lix-src;})];
  # moved to configuration.nix, stabilised
}
