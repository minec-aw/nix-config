{ config, pkgs, localPackages, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../shared-configurations.nix
    ../modules
  ];
  waydroid.enable = true;
  
}