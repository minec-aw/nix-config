{ pkgs, lib, config, ...}: {
  options = {
    tailscale.enable = lib.mkEnableOption "Enables tailscale";
  };
	config = lib.mkIf config.tailscale.enable {
		networking = {
			firewall = {
				trustedInterfaces = [ "tailscale0" ];
				allowedTCPPorts = [ 3389 2234 ];
			};
		};
		environment.systemPackages = [ pkgs.tail-tray ];
		services = {
			tailscale = {
				enable = true;
				useRoutingFeatures = "both";
				openFirewall = true;
			};
		};
	};
}