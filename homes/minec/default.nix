{ pkgs, ... }:
{
	# Define a user account. Don't forget to set a password with ‘passwd’.
	hjem.users.minec.files = {
		# Cursors & icons & themes
		".blerc".source = ./blesh-config.sh;
	};
	users.users.minec = {
		isNormalUser = true;
		description = "Minec";
		extraGroups = [ "networkmanager" "wheel" "adbusers" "kvm" "dialout" "flashrom" "corectrl" ];
		packages = with pkgs; [
			kdePackages.isoimagewriter
			kdiskmark
			easyeffects
			vscode
			prismlauncher
			protonplus
			krita
			r2modman
			qpwgraph
			tenacity
			scrcpy
			btop
			chromium
			vesktop
			faugus-launcher
			blender
			nicotine-plus
			libreoffice-fresh
			okteta
			pinta
			weasis
			direnv
			parsec-bin

			# Tools for a decent computer experience
			pwvucontrol
			loupe
			baobab
			resources
			gnome-disk-utility

			# Tools for other stuff
			git
			python3
			nodejs
			libqalculate
			jetbrains.webstorm
			bun

			# Theming
			apple-cursor
			/*libsForQt5.qt5ct
			kdePackages.qt6ct*/
			# For quickshell
			icoutils
			#localPackages.hyprfreeze
		];
	};
}
