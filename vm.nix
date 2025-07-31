{
  config,
  pkgs,
  ...
}: {
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["julia"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
