{ config, pkgs, localPackages, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../shared-configuration.nix
    ../../homes/minec
    ../../modules
  ];
  waydroid.enable = true;
  coding.enable = true;
  services = {
    displayManager = {
      sddm.enable = true;
    };
    plasma6.enable = true;
    printing.enable = true;
  };

  networking = {
    hostName = "linec";
    networkmanager.enable = true;
  };
}