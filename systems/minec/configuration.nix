{ config, pkgs, ... }:
{
	imports = [
		./hardware-configuration.nix
		../../homes/minec
		../shared-configuration.nix
		../../modules
	];
	superVirtualization = {
		enable = true;
		user = "minec";
	};
	programs.bash.shellAliases = {
		update = "nixos-rebuild switch --flake path:/home/minec/Shared/nix-config --sudo";
	};
	gaming.enable = true;
	coding.enable = true;
	nix-ld.enable = true;
	sunshine.enable = true;
	llama-cpp.enable = true;
	tilp.enable = true;
	environment.systemPackages = with pkgs; [
		weasis
		blender
		wineWow64Packages.staging
		parsec-bin
		winetricks
		imsprog
	];
	services.udev.extraRules = ''
        # CH341A Programmer
        SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="5512", MODE="0666"
    '';
	services.displayManager.autoLogin = {
		enable = true;
		user = "minec";
	};

 	hardware = {
		/*display = {
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
			};*/
		nvidia = {
			modesetting.enable = true;
			open = false;
			powerManagement.enable = true;
			prime = {
				reverseSync.enable = true;
				offload.enableOffloadCmd = true;
				# Enable if using an external GPU
				amdgpuBusId = "PCI:17:0:0";
				nvidiaBusId = "PCI:1:0:0";
			};
			nvidiaSettings = true;
			package = config.boot.kernelPackages.nvidiaPackages.beta;
		};
	};

  hjem.users.minec.files = {
    # Cursors & icons & themes
    ".config/niri/config.kdl".source = ./niri.kdl;
  };
}
