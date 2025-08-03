{ config, pkgs, inputs, localPackages, ... }:
let
  	wsuricons = pkgs.whitesur-icon-theme.override {
		alternativeIcons = true;
		themeVariants = ["red"];
	};
	gtk-theme = "${pkgs.orchis-theme}/share/themes/Orchis-Red-Dark";
in
{
	# Define a user account. Don't forget to set a password with ‘passwd’.
	hjem.users = {
		minec.files = {
			# Hyprland configurating
			/*".config/hypr/hyprland.conf".source = ./hyprland.conf;
			".config/hypr/xdph.conf".text = ''
				screencopy {
						allow_token_by_default = true
				}
			'';
			".config/quickshell".source = ./quickshell;
			# GTK
			".config/gtk-3.0/settings.ini".source = ./gtk-3.0;
			".config/gtk-4.0/settings.ini".source = ./gtk-4.0;
			".config/gtk-4.0/gtk.css".source = "${gtk-theme}/gtk-4.0/gtk.css";
			".config/gtk-4.0/gtk-dark.css".source = "${gtk-theme}/gtk-4.0/gtk-dark.css";
			".config/gtk-4.0/assets".source = "${gtk-theme}/gtk-4.0/assets";
			".themes/Orchis-Red".source = gtk-theme;
			#".themes/Orchis-Red-dark".source = "${gtk-theme}-Dark";

			".gtkrc-2.0".source = ./.gtkrc-2.0;*/

			# Cursors & icons & themes
			".local/share/icons/macOS".source = "${localPackages.macos-hyprcursor}/share/icons/macOS";
			".local/share/icons/macOS-x".source = "${pkgs.apple-cursor}/share/icons/macOS";
			".local/share/icons/WhiteSurIcons".source = "${wsuricons}/share/icons/WhiteSur-red";
			".local/share/icons/WhiteSurIcons-dark".source = "${wsuricons}/share/icons/WhiteSur-red-dark";
			".local/share/icons/WhiteSurIcons-light".source = "${wsuricons}/share/icons/WhiteSur-red-light";
			
			".config/ghostty/config".text = ''background = 000000
			gtk-gsk-renderer=opengl
			'';
			".config/fish".source = ./fish;
			
			".local/share/dev.mandre.rquickshare/.settings.json".text = ''{"port": "45978"}'';
		};
	};
	users.users.minec = {
		isNormalUser = true;
		description = "Minec";
		extraGroups = [ "networkmanager" "wheel" "adbusers" "kvm" "dialout" "flashrom" ];
		packages = with pkgs; [
			(inputs.zen-browser.packages."${system}".default.override {
				nativeMessagingHosts = [
					pkgs.firefoxpwa
					pkgs.kdePackages.plasma-browser-integration
				];
			})
      		(ghostty.overrideAttrs (_: {
				preBuild = ''
					shopt -s globstar
					sed -i 's/^const xev = @import("xev");$/const xev = @import("xev").Epoll;/' **/*.zig
					shopt -u globstar
				'';
			}))
			element-desktop
			nautilus
			python3
			vscode
			matugen
			weasis
			nodejs
			bun
			r2modman
			lutris
			umu-launcher
			qpwgraph
			tenacity
			scrcpy
			pinta
			rquickshare
			btop
			slack
			walker
			protonplus
			gh
			libqalculate
			grim
			(vesktop.override {
				withMiddleClickScroll = true;
			})
		];
	};
}
