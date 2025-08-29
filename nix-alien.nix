{
  config,
  pkgs,
  ...
}: let
  sources = import ./npins;
  nix-alien-pkgs = import sources.nix-alien {};
in {
  environment.systemPackages = with nix-alien-pkgs; [
    nix-alien
  ];
  # nix-ld added in builtin-programs.nix
}
