let
  sources = import ./npins;
in
{
  meta = {
    nixpkgs = import sources.nixpkgs;
    specialArgs = { inherit sources; };
  };

  defaults =
    { lib, name, ... }:
    {
      imports = [
        # ./nixos/nixpkgs.nix
        # ./nixos/common.nix
      ];
      config = {
        networking.hostName = name;
        deployment = {
          targetUser = lib.mkDefault null;
          sshOptions = [
            "-o"
            "ConnectTimeout=30"
            "-o"
            "ServerAliveInterval=30"
            "-o"
            "ServerAliveCountMax=2"
          ];
        };
      };
    };

  argon = {
    imports = [
      ./nixos/secure-boot.nix
      ./nixos/tarsnap.nix
      ./argon/configuration.nix
      "${sources.nixos-hardware}/framework/13-inch/13th-gen-intel"
      ./argon/hardware-configuration.nix
      "${sources.agenix}/modules/age.nix"
      "${sources.home-manager}/nixos"
      (
        { config, lib, ... }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.gmacon.imports = [
            "${sources.nix-index-database}/home-manager-module.nix"
            ./home-manager/common/common.nix
            ./home-manager/common/linux.nix
            ./home-manager/graphical/common.nix
            ./home-manager/graphical/linux.nix
            ./home-manager/home/common.nix
          ];
          home-manager.extraSpecialArgs = {
            inherit sources;
            username = "gmacon";
            userEmail = "george@themacons.net";
            homeDirectory = "/home/gmacon";
            unstablePkgs = import sources.nixpkgs-unstable {
              inherit (config.nixpkgs) overlays config;
            };
          };
        }
      )
    ];
    deployment = {
      allowLocalDeployment = true;
      targetHost = null;
    };
  };

  phosphorus = {
    imports = [
      ./phosphorus/configuration.nix
      ./phosphorus/hardware-configuration.nix
    ];
    deployment = {
      targetHost = "phosphorus.tail6afb0.ts.net";
    };
  };

  silicon = {
    nixpkgs.hostPlatform.system = "aarch64-linux";
    imports = [
      "${sources.nixos-hardware}/raspberry-pi/4"
      "${sources.agenix}/modules/age.nix"
      ./silicon/configuration.nix
      (import ./nixos/modules/beeper-mautrix.nix "discord")
      ./nixos/beeper-bridges
    ];
    deployment = {
      targetHost = "silicon.tail6afb0.ts.net";
    };
  };

  potassium = {
    imports = [
      "${sources.nixpkgs}/nixos/modules/virtualisation/digital-ocean-config.nix"
      ./nixos/tarsnap.nix
      ./potassium/configuration.nix
      "${sources.agenix}/modules/age.nix"
      ./potassium/web-server.nix
    ];
    deployment = {
      targetHost = "potassium.tail6afb0.ts.net";
      targetUser = "root";
    };
  };

  calcium = {
    nixpkgs.hostPlatform.system = "aarch64-linux";
    imports = [
      "${sources.nixos-hardware}/raspberry-pi/3"
      "${sources.agenix}/modules/age.nix"
      ./calcium/configuration.nix
    ];
    deployment = {
      targetHost = "calcium.tail6afb0.ts.net";
    };
  };
}
