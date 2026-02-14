# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, localPackages, inputs, ... }:
{
	imports = [ # Include the results of the hardware scan.
		./hardware-configuration.nix
		./homes/minec
		./virtualisation
	];
	# Set your time zone.
	#users.users.immich.extraGroups = [ "video" "render" ];

	
	# Allow unfree packages
	
	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment = {

		systemPackages = with pkgs;
		[	
			# Theming
			darkly-qt5
			darkly
			adw-gtk3

			# cosmic
			
		];
	};
	system.stateVersion = "25.05"; # Did you read the comment?

}
