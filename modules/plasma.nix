{pkgs, lib, config, ...}: {
  options = {
    plasma.enable = lib.mkEnableOption "Enables KDE plasma and the niceities i put with it";
  };
  config = lib.mkIf config.plasma.enable {
    services = {
      displayManager = {
        sddm.enable = true;
      };
      desktopManager.plasma6.enable = true;
      printing.enable = true;
    };
  };
}