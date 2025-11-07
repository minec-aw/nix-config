{ pkgs, ... }:
let
  	wsuricons = pkgs.whitesur-icon-theme.override {
		alternativeIcons = true;
		themeVariants = ["red"];
	};
in
{
	# Define a user account. Don't forget to set a password with ‘passwd’.
	hjem.users.minec.files = {
		#".config/openxr/1/active_runtime.json".source = "${pkgs.wivrn}/share/openxr/1/openxr_wivrn.json";
		".config/openvr/openvrpaths.vrpath".text = ''
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
		'';
		/*".config/hypr/hyprland.conf".source = ./hyprland.conf;
		".config/hypr/xdph.conf".text = ''
			screencopy {
				allow_token_by_default = true
			}
		'';
		".config/quickshell".source = ./quickshell;*/

		# Cursors & icons & themes
		".local/share/icons/macOS-x".source = "${pkgs.apple-cursor}/share/icons/macOS";
		".local/share/icons/WhiteSurIcons".source = "${wsuricons}/share/icons/WhiteSur-red";
		".local/share/icons/WhiteSurIcons-dark".source = "${wsuricons}/share/icons/WhiteSur-red-dark";
		".local/share/icons/WhiteSurIcons-light".source = "${wsuricons}/share/icons/WhiteSur-red-light";
		
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
      		ghostty
			element-desktop
			#nautilus
			pwvucontrol
			isoimagewriter
			kdiskmark
			easyeffects
			gnome-disk-utility
			git
			#ungoogled-chromium
			python3
			vscode-fhs
			nodejs
			r2modman
			prismlauncher
			qpwgraph
			tenacity
			scrcpy
			krita
			btop
			protonplus
			resources
			#libsForQt5.qt5ct
			#qt6ct
			#stremio
			libqalculate
			/*(vesktop.override {
				withMiddleClickScroll = true;
			})*/
			chromium
			vesktop
			tagger
			/*(discord.override {
				withOpenASAR = true;
				withMoonlight = true; # can do this here too
			})*/
			kde-rounded-corners
			faugus-launcher
			#kdePackages.discover
			#kdePackages.dolphin-plugins
      		#kdePackages.gwenview
			#kdePackages.kservice
			#kdePackages.kde-cli-tools
			#kdePackages.ffmpegthumbs
			#kdePackages.kio
			#kdePackages.kio-extras
			#kdePackages.kio-fuse
			#kdePackages.kimageformats
			#kdePackages.kdegraphics-thumbnailers
		];
	};
}
