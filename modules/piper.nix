{ pkgs, lib, config, ...}: {
  options = {
    piper.enable = lib.mkEnableOption "Enables piper for editing mouse settings";
  };
  config = lib.mkIf config.piper.enable {
    environment.systemPackages = (with pkgs; [
      piper
    ]);
    services.ratbagd.enable = true;
  };
}