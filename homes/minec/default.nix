{ pkgs, localPackages, ... }:
let
  wsuricons = pkgs.whitesur-icon-theme.override {
		alternativeIcons = true;
		themeVariants = ["purple"];
	};
	/*gtk-theme = "${
		pkgs.catppuccin-gtk.override {
			accents = ["lavender"];
			variant = "mocha";
		}
	}/share/themes/catppuccin-mocha-lavender-standard";*/
in
{
	# Define a user account. Don't forget to set a password with ‘passwd’.
	hjem.users.minec.files = {
		".config/openxr/1/active_runtime.json".source = "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";
		/*".config/openvr/openvrpaths.vrpath".text = ''
			{
				"config" :
				[
				"/home/minec/.local/share/Steam/config"
				],
				"external_drivers" : null,
				"jsonid" : "vrpathreg",
				"log" :
				[
				"/home/minec/.local/share/Steam/logs"
				],
				"runtime" :
				[
				"${pkgs.xrizer}/lib/xrizer"
				],
				"version" : 1
			}
			'';*/
		".config/hypr/hyprland.conf".source = ./hyprland.conf;
		".config/hypr/xdph.conf".text = ''
			screencopy {
				allow_token_by_default = true
			}
		'';
		".config/quickshell".source = ./quickshell;

		# Cursors & icons & themes
		".local/share/icons/macOS-x".source = "${pkgs.apple-cursor}/share/icons/macOS";
		".local/share/icons/WhiteSurIcons".source = "${wsuricons}/share/icons/WhiteSur-purple";
		".local/share/icons/WhiteSurIcons-dark".source = "${wsuricons}/share/icons/WhiteSur-purple-dark";
		".local/share/icons/WhiteSurIcons-light".source = "${wsuricons}/share/icons/WhiteSur-purple-light";
		/*".config/xsettingsd/xsettingsd.conf".source = ./xsettingsd.conf;
		".config/gtk-3.0/settings.ini".source = ./gtk-3.0;
		".config/gtk-4.0/settings.ini".source = ./gtk-4.0;
		".config/gtk-4.0/gtk.css".source = "${gtk-theme}/gtk-4.0/gtk.css";
		".config/gtk-4.0/gtk-dark.css".source = "${gtk-theme}/gtk-4.0/gtk-dark.css";
		".config/gtk-4.0/assets".source = "${gtk-theme}/gtk-4.0/assets";
		".themes/catppuccin-mocha-lavender-standard".source = gtk-theme;
		".gtkrc-2.0".source = ./gtkrc-2.0;*/

		".config/ghostty/config".text = ''
		background = 000000
		cursor-style = bar
		cursor-style-blink = true
		'';
		".blerc".source = ./blesh-config.sh;

		".local/share/dev.mandre.rquickshare/.settings.json".text = ''{"port": "45978"}'';
	};
	users.users.minec = {
		isNormalUser = true;
		description = "Minec";
		extraGroups = [ "networkmanager" "wheel" "adbusers" "kvm" "dialout" "flashrom" "corectrl" ];
		packages = with pkgs; [
      		# Apps
			ghostty
			element-desktop
			kdePackages.kdenlive
			#jellyfin-media-player
			kdePackages.isoimagewriter
			kdiskmark
			easyeffects
			vscode-fhs
			prismlauncher
			protonplus
			krita
			r2modman
			qpwgraph
			#tenacity
			scrcpy
			btop
			chromium
			vesktop
			faugus-launcher
			bluejay
			blender
			rquickshare

			# Tools for a decent computer experience
			#vicinae
			#nautilus
			pwvucontrol
			#kdePackages.ark
			resources
			#loupe
			#showtime
			#gnome-text-editor
			#decibels
			gnome-disk-utility

			# Tools for other stuff
			git
			python3
			nodejs
			libqalculate
			

			# Theming
			kde-rounded-corners
			/*libsForQt5.qt5ct
			kdePackages.qt6ct*/
			# For quickshell
			icoutils
			localPackages.hyprfreeze
		];
	};
}
