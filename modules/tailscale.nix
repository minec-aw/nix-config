{ pkgs, lib, config, ...}: {
  options = {
    tailscale.enable = lib.mkEnableOption "Enables tailscale";
  };
  networking = {
		firewall = {
			trustedInterfaces = lib.mkIf config.tailscale.enable [ "tailscale0" ];
			allowedTCPPorts = lib.mkIf config.tailscale.enable [ 3389 2234 ];
		};
	};
	environment.systemPackages = lib.mkIf config.tailscale.enable [ pkgs.tail-tray ];
  services = {
    tailscale = lib.mkOption config.tailscale.enable {
			enable = true;
			useRoutingFeatures = "both";
			openFirewall = true;
		};
  };
}