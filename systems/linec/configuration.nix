{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../shared-configuration.nix
    ../../homes/minec
    ../../modules
  ];
  waydroid.enable = true;
  coding.enable = true;
  services.printing.enable = true;
  environment.systemPackages = [ pkgs.moonlight-qt ];
  services.thermald.enable = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  networking = {
    hostName = "linec";
    networkmanager.enable = true;
  };
}