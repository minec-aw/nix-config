{ config, pkgs, localPackages, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../shared-configuration.nix
    ../../modules
  ];
  waydroid.enable = true;
  
}