{ pkgs, lib, ... }:
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
    update = "nixos-rebuild switch --flake path:/home/minec/Shared/nix-config --sudo --build-host minec@192.168.68.60";
  };
  boot.kernelParams = ["mem_sleep_default=deep"];
  services = {
    printing.enable = true;
    thermald.enable = true;
  };
  environment.systemPackages = with pkgs; [
    moonlight-qt
    swayidle
  ];
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

  hjem.users.minec.files = {
		# Cursors & icons & themes
		".config/niri/config.kdl".source = ./niri.kdl;
	};

}
