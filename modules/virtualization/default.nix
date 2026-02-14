{ lib, config, ...}: {
  options = {
    superVirtualization.enable = lib.mkEnableOption "enables nvidia gpu kind of virtualization + docker and other stuff";
    waydroid.enable = lib.mkEnableOption "Enables waydroid";
  };

  virtualisation.waydroid.enable = lib.mkIf config.waydroid.enable true;
  imports = lib.mkIf config.superVirtualization.enable [
    ./virt
  ];
}