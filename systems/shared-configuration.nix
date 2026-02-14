{ pkgs, inputs, ...}: {
  imports = [
    ../modules
  ];
  # These are non-negotiables
  hjem.clobberByDefault = true;
  font-config.enable = true;
  nix-ld.enable = true;
  tailscale.enable = true;
  desktop-apps.enable = true;
  systemd-boot.enable = true;

  environment = {
    shells = with pkgs; [bash];
		sessionVariables = {
			ELECTRON_OZONE_PLATFORM_HINT = "wayland";
			NIXOS_OZONE_WL = 1;
			PROTON_ENABLE_WAYLAND = 1;
			COSMIC_DATA_CONTROL_ENABLED = 1;
			#QML_IMPORT_PATH = "${pkgs.hyprland-qt-support}/lib/qt-6/qml";
		};
    systemPackages = with pkgs; [
      fastfetch
      appimage-run
      unrar
      pulseaudio
    ];
  };
  services = {
    openssh.enable = true;
		gvfs.enable = true;
    dbus.implementation = "broker";
    flatpak.enable = true;
		pipewire = {
			enable = true; # if not already enabled
			alsa.enable = true;
			alsa.support32Bit = true;
			pulse.enable = true;
			jack.enable = true;
		};
  };
  i18n.defaultLocale = "en_CA.UTF-8";

	i18n.extraLocales = ["en_CA.UTF-8/UTF-8" "en_US.UTF-8/UTF-8"];
  time = {
		timeZone = "America/Toronto";
		hardwareClockInLocalTime = true;
	};
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    graphics = {
			enable = true;
			enable32Bit = true;
			#package = pkgs-mesa-pin.mesa;
			#package32 = pkgs-mesa-pin.driversi686Linux.mesa;
			extraPackages = with pkgs; [
				nvidia-vaapi-driver
				vulkan-loader
				vulkan-tools
			];
		};
  };
  nixpkgs = {
		config = {
			allowUnfree = true;
			android_sdk.accept_license = true;
		};
	};
  security = {
		polkit.enable = true;
		rtkit.enable = true;
		#soteria.enable = true;
	};
  programs = {
    #corectrl.enable = true;
    kdeconnect = {
      enable = true;
    };
    bash = {
      enable = true;
      blesh.enable = true;
    };
    nh = {
      enable = true;
    };
  };
  nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];

	nix.settings = {
		auto-optimise-store = true;
		experimental-features = [ "nix-command" "flakes" ];
	};
}