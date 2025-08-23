# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:
{
	imports = [ # Include the results of the hardware scan.
		./hardware-configuration.nix
		./refind/refind.nix
		./homes/minec
	];
	hjem.clobberByDefault = true;
	boot = {
		kernelParams = ["quiet" "splash" "loglevel=3"];
		/*extraModprobeConfig = ''
			options nvidia NVreg_UsePageAttributeTable=1 NVreg_InitializeSystemMemoryAllocations=0 NVreg_EnableStreamMemOPs=1 NVreg_EnableGpuFirmware=0
		'';*/
		consoleLogLevel = 0;
		loader = {
			refind = {
				enable = true;
				extraConfig = ''
				include prioboot.conf
				enable_mouse true
				resolution 2560 1440
				mouse_speed 10
				mouse_size 22
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
			allowedTCPPortRanges = [{
				from = 1714;
				to = 1764;
			}];
			allowedUDPPortRanges = [{
				from = 1714;
				to = 1764;
			}];
			trustedInterfaces = [ "tailscale0" ];
			allowedUDPPorts = [ config.services.tailscale.port 47998 47999 48000 48002 48010 21538 22000 21027 45978 ];
			allowedTCPPorts = [ 22 4000 47984 47989 48010 47990 21538 8384 22000 21538 45978 ];
		};
	};
	systemd.user.services.wivrn.serviceConfig.RemoveIPC = pkgs.lib.mkForce false;
	# Set your time zone.
	time = {
		timeZone = "America/Toronto";
		hardwareClockInLocalTime = true;
	};

	# Select internationalisation properties.
	i18n.defaultLocale = "en_CA.UTF-8";

	i18n.extraLocales = ["en_CA.UTF-8/UTF-8" "en_US.UTF-8/UTF-8"];


	services = {
		xserver.xkb = {
			layout = "us";
			variant = "";
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
		desktopManager.plasma6.enable = true;
		displayManager = {
			autoLogin = {
				enable = true;
				user = "minec";
			};
			sddm = {
				enable = true;
				wayland.enable = true;
				autoLogin.relogin = true;
			};
		};

		/*greetd = {
			enable = true;
			settings = {
				initial_session = {
					command = "${pkgs.hyprland}/bin/Hyprland";
					user = "minec";
				};
				default_session = {
					command = "$${pkgs.greetd.tuigreet}/bin/tuigreet --greeting 'Welcome to NixOS!' --asterisks --remember --remember-user-session --time -cmd ${pkgs.hyprland}/bin/Hyprland";
					user = "greeter";
				};
			};
		};*/
		tailscale = {
			enable = true;
			useRoutingFeatures = "both";
			openFirewall = true;
		};
		xserver.videoDrivers = [ "nvidia" "amdgpu" ];
		openssh.enable = true;
		gvfs.enable = true;
		sunshine = {
			enable = true;
			package = (pkgs.sunshine.override {
				cudaSupport = true;
			});
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
		/*display = {
			edid = {
				enable = true;
				modelines = {
					#"Sunshine" = "368.76  1920 2072 2288 2656  1080 1081 1084 1157  -hsync +vsync";
					#"PG278Q_120" = "   497.75   2560 2608 2640 2720   1440 1443 1448 1525   +hsync -vsync";
				};
				packages = [
					(pkgs.runCommand "edid-creation" {} ''
						mkdir -p "$out/lib/firmware/edid"
						cp "${./customdp}" $out/lib/firmware/edid/wh.bin
					'')
				];
			};
			outputs."HDMI-A-2" = {
    			edid = "wh.bin";
        		mode = "e";
      		};
		};*/
		bluetooth = {
			enable = true;
			powerOnBoot = true;
		};
		graphics = {
			enable = true;
			enable32Bit = true;
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
		};
	};
	security = {
		polkit.enable = true;
		#soteria.enable = true;
		rtkit.enable = true;
	};
	# List packages installed in system profile. To search, run:
	# $ nix search wget
	environment = {
		shells = with pkgs; [bash];
		variables = {
			/*MOZ_DISABLE_RDD_SANDBOX = "1";
			LIBVA_DRIVER_NAME = "nvidia";
			GBM_BACKEND = "nvidia-drm";
			__GLX_VENDOR_LIBRARY_NAME = "nvidia";
			NVD_BACKEND = "direct";*/
			#EGL_PLATFORM = "wayland";
			#WLR_NO_HARDWARE_CURSORS = "1";
		};

		systemPackages = with pkgs; 
		let 
			wsuricons = whitesur-icon-theme.override {
				alternativeIcons = true;
				themeVariants = ["red"];
			};
		in
		[
			#  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
			#  wget
			zed-editor
			
			#grim
			jq
			#hyprpicker
			socat
			sysstat
			imagemagick

			wofi
			#blueberry
			hyprpolkitagent
			gnome-disk-utility
			git
			#(inputs.quickshell.packages.x86_64-linux.default.withModules [ kdePackages.qtmultimedia ])
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
			easyeffects
			pwvucontrol
			isoimagewriter
			kdiskmark
			
			wsuricons
			orchis-theme
			arduino-ide
			kdePackages.plasma-browser-integration

			darkly-qt5
			darkly
			kde-rounded-corners
			tail-tray
			wayvr-dashboard
			wlx-overlay-s
			ungoogled-chromium
			#nvidia-vaapi-driver
			vaapiVdpau
			libvdpau-va-gl
			libva
			libva-utils
			ffmpeg
			inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin
		];
	};
	nix.settings = {
		auto-optimise-store = true;
		experimental-features = [ "nix-command" "flakes" ];
		#substituters = ["https://hyprland.cachix.org"];
		#trusted-substituters = ["https://ai.cachix.org"];
		#trusted-public-keys = ["ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc=" "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
	};

	programs = {
		#hyprland.enable = true;
		fish.enable = true;
		flashrom.enable = true;
		obs-studio = {
			enable = true;
			package = (pkgs.obs-studio.override {
				cudaSupport = true;
			});
		};
		kdeconnect = {
			enable = true;
		};
		adb.enable = true;
		bash = {
			interactiveShellInit = ''
				if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
				then
				shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
				exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
				fi
			'';
		};
		dconf = {
			enable = true;
			profiles.user.databases = [{
				settings."org/gnome/desktop/interface" = {
					gtk-theme = "Orchis-Red-Dark";
					icon-theme = "WhiteSur-Red";
					font-name = "Noto Sans Medium 11";
					color-scheme = "prefer-dark";
					document-font-name = "Noto Sans Medium 11";
					monospace-font-name = "Noto Sans Mono Medium 11";
				};
			}];
		};
		
		nh = {
			enable = true;	
		};
		steam = {
			#gamescopeSession.enable = true;
			enable = true;
			protontricks.enable = true;
			extraCompatPackages = with pkgs; [
				proton-ge-bin
			];
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
	# Open ports in the firewall.
	# networking.firewall.allowedTCPPorts = [ ... ];
	# networking.firewall.allowedUDPPorts = [ ... ];
	# Or disable the firewall altogether.
	# networking.firewall.enable = false;

	# This value determines the NixOS release from which the default
	# settings for stateful data, like file locations and database versions
	# on your system were taken. It‘s perfectly fine and recommended to leave
	# this value at the release version of the first install of this system.
	# Before changing this value read the documentation for this option
	# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
	system.stateVersion = "25.05"; # Did you read the comment?

}
