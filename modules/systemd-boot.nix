{ pkgs, lib, config, ...}: {
  options = {
    systemd-boot.enable = lib.mkEnableOption "Enable systemd boot";
  };
  boot = lib.mkIf config.systemd-boot.enable {		
		kernelParams = ["quiet" "splash" "loglevel=3"];
		consoleLogLevel = 0;
		loader = {
			systemd-boot = {
				enable = true;
				editor = false;
			};
			timeout = 2;
			efi.canTouchEfiVariables = true;
		};

		initrd = {
			verbose = true;
			systemd.enable = true;
		};
		plymouth = {
			enable = true;
			theme = "bgrt";
			extraConfig = "DeviceScale=1";
		};
		kernelPackages = pkgs.linuxPackages_latest; 
	};
}