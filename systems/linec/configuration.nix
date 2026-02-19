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
  programs.bash.shellAliases = {
    update = "nixos-rebuild switch --flake path:/home/minec/Shared/nixos --sudo --build-host minec@192.168.68.60";
  };
  services = {
    printing.enable = true;
    thermald.enable = true;
  };
  environment.systemPackages = [ pkgs.moonlight-qt ];
  hardware.sensor.iio.enable = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  networking = {
    hostName = "linec";
    nftables.enable = true;
    networkmanager.enable = true;
  };
}
