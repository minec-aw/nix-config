{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../homes/minec
    ../shared-configuration.nix
    ../../modules
  ];
  superVirtualization.enable = true;
  gaming.enable = true;
  coding.enable = true;
  nix-ld.enable = true;
	sunshine.enable = true;
  environment.systemPackages = with pkgs; [
    cosmic-ext-applet-minimon
		cosmic-ext-tweaks
    weasis
    blender
    parsec-bin
  ];
  services = {
		/*syncthing = {
			enable = true;
			openDefaultPorts = true;
			relay.enable = true;
		};*/
		desktopManager.cosmic = {
			enable = true;
		};

		displayManager = {
			autoLogin = {
				enable = true;
				user = "minec";
			};
			cosmic-greeter = {
				enable = true;
			};
		};
	};

  hardware = {
		display = {
			edid = {
				enable = true;
				packages = [
					(pkgs.runCommand "edid-creation" {} ''
						mkdir -p "$out/lib/firmware/edid"
						cp "${../../edidFiles/SamsungTV}" $out/lib/firmware/edid/wh.bin
					'')
					(pkgs.runCommand "edid-creation" {} ''
						mkdir -p "$out/lib/firmware/edid"
						cp "${../../edidFiles/Empty}" $out/lib/firmware/edid/ignored.bin
					'')
				];
			};
			outputs."DP-1" = {
				edid = "wh.bin";
				mode = "e";
			};
		};
    nvidia = {
			modesetting.enable = true;
			open = true;
			powerManagement.enable = true;
			prime = {
				reverseSync.enable = true;
				offload.enableOffloadCmd = true;
				# Enable if using an external GPU
				amdgpuBusId = "PCI:17:0:0";
				nvidiaBusId = "PCI:1:0:0";
			};
			nvidiaSettings = true;
			package = config.boot.kernelPackages.nvidiaPackages.latest;
		};
  };
}