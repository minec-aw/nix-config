# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs-mesa-pin, vicinae, localPackages, inputs, ... }:
{
	imports = [ # Include the results of the hardware scan.
		./hardware-configuration.nix
		./refind/refind.nix
		./homes/minec
		./virtualisation
	];

	hjem.clobberByDefault = true;
	boot = {
		kernelParams = ["quiet" "splash" "loglevel=3"];
		kernel.sysctl = {
			"vm.swappiness" = 20;
		};
		/*extraModprobeConfig = ''
			options nvidia NVreg_UsePageAttributeTable=1 NVreg_InitializeSystemMemoryAllocations=0 NVreg_EnableStreamMemOPs=1 NVreg_EnableGpuFirmware=0
		'';*/
		consoleLogLevel = 0;
		loader = {
			refind = {
				enable = true;
				extraConfig = ''
				enable_mouse true
				mouse_speed 10
				mouse_size 22
				textonly 0
				resolution 2560 1440
				scan_driver_dirs drivers,EFI/tools/drivers
				include themes/rEFInd-minimal/theme.conf
				dont_scan_dirs efi/nixos
				'';
				additionalFiles = {
					"themes/rEFInd-minimal" = "${builtins.path { path = ./refind; }}/rEFInd-minimal-modded-theme";
				};
			};
			# until refind is merged into nixpkgs, this must be here
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
	networking = {
		hostName = "minec";
		networkmanager.enable = true;
		firewall = {
			enable = true;
			trustedInterfaces = [ "tailscale0" ];
		};
	};
	systemd.user.services.wivrn.serviceConfig.RemoveIPC = pkgs.lib.mkForce false;
	zramSwap = {
		enable = true;
		swapDevices = 0;
	};
	# Set your time zone.
	time = {
		timeZone = "America/Toronto";
		hardwareClockInLocalTime = true;
	};

	# Select internationalisation properties.
	i18n.defaultLocale = "en_CA.UTF-8";

	i18n.extraLocales = ["en_CA.UTF-8/UTF-8" "en_US.UTF-8/UTF-8"];
	users.users.immich.extraGroups = [ "video" "render" ];
	services = {
		xserver = {
			videoDrivers = [ "nvidia" "amdgpu" ];
			xkb = {
				layout = "us";
				variant = "";
			};
		};
		immich = {
			enable = true;
			port = 2283;
			host = "100.70.40.10";
			accelerationDevices = [ "/dev/dri/renderD128" ];
			#mediaLocation = "/media/Storage/immich";
			openFirewall = true;
		};
		syncthing = {
			enable = true;
			openDefaultPorts = true;
			relay.enable = true;
		};
		dbus.implementation = "broker";
		wivrn = {
			enable = true;
			openFirewall = true;
			package = (pkgs.wivrn.override {
				cudaSupport = true;
			});
			#defaultRuntime = true;
		};
		playerctld.enable = true;
		#desktopManager.plasma6.enable = true;
		/*greetd = {
			enable = true;
			settings = {
				initial_session = {
					command = "${pkgs.hyprland}/bin/Hyprland";
					user = "minec";
				};
				default_session = {
					command = "$${pkgs.greetd.tuigreet}/bin/tuigreet --greeting ' ' --asterisks --remember --remember-user-session --time -cmd ${pkgs.hyprland}/bin/Hyprland";
					user = "greeter";
				};
			};
		};*/
		displayManager = {
			autoLogin = {
				enable = true;
				user = "minec";
			};
			sddm = {
				enable = true;
				wayland.enable = true;
				#autoLogin.relogin = true;
			};
		};
		tailscale = {
			enable = true;
			useRoutingFeatures = "both";
			openFirewall = true;
		};
		
		openssh.enable = true;
		gvfs.enable = true;
		sunshine = {
			enable = true;
			/*package = (pkgs.sunshine.override {
				cudaSupport = true;
			});*/
			capSysAdmin = true;
			settings = {
				sunshine_name = "Minec";
			};
			openFirewall = true;
			autoStart = true;
		};
		flatpak.enable = true;
		pipewire = {
			enable = true; # if not already enabled
			alsa.enable = true;
			alsa.support32Bit = true;
			pulse.enable = true;
			jack.enable = true;
		};
	};
	
	hardware = {
		i2c.enable = true;
		display = {
			edid = {
				enable = true;
				packages = [
					(pkgs.runCommand "edid-creation" {} ''
						mkdir -p "$out/lib/firmware/edid"
						cp "${./edidFiles/SamsungTV}" $out/lib/firmware/edid/wh.bin
					'')
					(pkgs.runCommand "edid-creation" {} ''
						mkdir -p "$out/lib/firmware/edid"
						cp "${./edidFiles/Empty}" $out/lib/firmware/edid/ignored.bin
					'')
					
				];
			};
			/*outputs."HDMI-A-2" = {
    			edid = "ignored.bin";
        		mode = "d";
      		};
			outputs."HDMI-A-3" = {
    			edid = "ignored.bin";
        		mode = "d";
      		};*/
		};
		bluetooth = {
			enable = true;
			powerOnBoot = true;
		};
		graphics = {
			enable = true;
			enable32Bit = true;
			package = pkgs-mesa-pin.mesa;
			package32 = pkgs-mesa-pin.driversi686Linux.mesa;
			extraPackages = with pkgs; [
				nvidia-vaapi-driver
			];
		};
		nvidia = {
			modesetting.enable = true;
			open = true;
			powerManagement.enable = true;
			prime = {
				reverseSync.enable = true;
				offload.enableOffloadCmd = true;
				# Enable if using an external GPU
				amdgpuBusId = "PCI:6:0:0";
				nvidiaBusId = "PCI:43:0:0";
			};
			nvidiaSettings = true;
			package = config.boot.kernelPackages.nvidiaPackages.latest;
		};
	};
	# Allow unfree packages
	nixpkgs = {
		config = {
			allowUnfree = true;
			android_sdk.accept_license = true;
			permittedInsecurePackages = [
                 "qtwebengine-5.15.19"
        	];
		};
	};
	security = {
		polkit.enable = true;
		rtkit.enable = true;
		soteria.enable = true;
	};
	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment = {
		shells = with pkgs; [bash];
		sessionVariables = {
			HYPR_PLUGIN_DIR = pkgs.symlinkJoin {
				name = "hyprland-plugins";
				paths = with pkgs.hyprlandPlugins; [
					hyprgrass
				];
			};
			QML_IMPORT_PATH = "${pkgs.hyprland-qt-support}/lib/qt-6/qml";
		};
		systemPackages = with pkgs; 
		let 
			wsuricons = whitesur-icon-theme.override {
				alternativeIcons = true;
				themeVariants = ["red"];
			};
		in
		[
			jq
			socat
			sysstat
			imagemagick
			(inputs.zen-browser.packages."${system}".default.override {
				nativeMessagingHosts = [
					pkgs.kdePackages.plasma-browser-integration
				];
			})
			#hyprpolkitagent
			fastfetch
			flatpak
			wget
			lshw
			unrar
			chntpw
			libnotify
			appimage-run
			lsof
			psmisc
			wl-clipboard
			
			wsuricons

			darkly-qt5
			darkly
			#tail-tray
			wayvr-dashboard
			wlx-overlay-s
			vlc
			vicinae


			kdePackages.plasma-browser-integration
			kdePackages.ark
			kdePackages.dolphin
			quickshell
			#(inputs.quickshell.packages.x86_64-linux.default.withModules [ kdePackages.qtmultimedia ])
			#ffmpeg
		];
	};
	nix.settings = {
		auto-optimise-store = true;
		experimental-features = [ "nix-command" "flakes" ];
	};

	programs = {
		corectrl.enable = true;
		obs-studio = {
			enable = true;
		};
		hyprland = {
			enable = true;
			withUWSM = true;
			#package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
			#portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
		};
		dconf.enable = true;
		firefox = {
			enable = true;
			#nativeMessagingHosts.packages = [ pkgs.firefoxpwa ];
		};
		kdeconnect = {
			enable = true;
		};
		adb.enable = true;
		bash = {
			enable = true;
			blesh.enable = true;
		};
		nh = {
			enable = true;	
		};
		steam = {
			#gamescopeSession.enable = true;
			enable = true;
			protontricks.enable = true;
			package = with pkgs; steam.override {
				extraPkgs = pkgs: [
					attr
				];
				extraLibraries = (pkgs: [
					#(pkgs.callPackage ./LocalPackages/openssl {}).openssl_1_1
					pkgs.openssl
					pkgs.nghttp2
					pkgs.fontconfig
					pkgs.libidn2
					pkgs.rtmpdump
					pkgs.libpsl
					pkgs.curl
					pkgs.krb5
					pkgs.keyutils
				]);
			};
			remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
			#dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
		};
	};
	fonts = {
		fontDir.enable = true;
		fontconfig.enable = true;
		fontconfig.cache32Bit = true;
		packages = with pkgs; [
			noto-fonts
			noto-fonts-cjk-sans
			noto-fonts-emoji
			liberation_ttf
			fira-code
			fira-code-symbols
			mplus-outline-fonts.githubRelease
			dina-font
			proggyfonts
			#nerdfonts
			nerd-fonts.fira-code
  			nerd-fonts.droid-sans-mono
			corefonts
			liberation_ttf
			vistafonts
			jetbrains-mono
			#inputs.apple-fonts.packages.${pkgs.system}.sf-pro
		];
	};
	system.stateVersion = "25.05"; # Did you read the comment?

}
