{ config, lib, pkgs, localPackages, pkgs-mesa-pin, modulesPath, ... }:
{
	boot = {
		blacklistedKernelModules = [ "nvidia" "nouveau" "nvidia_drm" "nvidia_uvm" "nvidia_modeset" ]; ##passthrough stuff
		kernelModules = ["vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio"]; ##passthrough stuff
		kernelParams = ["intel_iommu=on" "iommu=pt" "vfio_iommu_type1.allow_unsafe_interrupts=1" "kvm.ignore_msrs=1" "vfio-pci.ids=10de:2504,10de:228e" "kvmfr.static_size_mb=128"];
		initrd.kernelModules = [ "kvmfr" ];
		extraModulePackages = with config.boot.kernelPackages; [
			kvmfr
		];
	};
	virtualisation = {
		waydroid.enable = true;
		libvirtd = {
			onBoot = "ignore";
			onShutdown = "shutdown";
			enable = true;
			qemu = {
				swtpm.enable = true;
				ovmf.enable = true;
				ovmf.packages = [ pkgs.OVMFFull.fd ];
				verbatimConfig = ''
					namespaces = []
					cgroup_device_acl = [
						"/dev/null", "/dev/full", "/dev/zero",
						"/dev/random", "/dev/urandom",
						"/dev/ptmx", "/dev/kvm",
						"/dev/userfaultfd", "/dev/kvmfr0"
					]
				'';
			};
		};
		spiceUSBRedirection.enable = true;
	};

	systemd.services.libvirtd = {
    	path = let
            env = pkgs.buildEnv {
				name = "qemu-hook-env";
				paths = with pkgs; [
					bash
					libvirt
					kmod
					systemd
					gawk
					sd
					lsof
					psmisc
					localPackages.nvidia-bind-vfio
					localPackages.nvidia-unbind-vfio
				];
			};
           in
           [ env ];
		
    	preStart =
		''
		mkdir -p /var/lib/libvirt/hooks

		cp -r -f ${./qemu} /var/lib/libvirt/hooks/qemu
		chmod +x /var/lib/libvirt/hooks/qemu
		'';
	};
	security.sudo.extraRules = [
		{
			groups = ["libvirtd"];
			commands = [
				{
					command = "/run/current-system/sw/bin/nvidia-bind-vfio"; 
					options = ["NOPASSWD"];
				}
				{
					command = "/run/current-system/sw/bin/nvidia-unbind-vfio"; 
					options = ["NOPASSWD"];
				}
			];
		}
	];
	environment.systemPackages = with pkgs; [
		qemu_kvm
		lsof
		virt-manager
		virt-viewer
		spice
		spice-gtk
		spice-protocol
		virtiofsd
		ebtables
		psmisc
		pciutils
		libvncserver
		looking-glass-client

		localPackages.nvidia-bind-vfio
		localPackages.nvidia-unbind-vfio
	];
	users.groups = {
		libvirtd = {
			members = ["minec"];
		};
		input = {
			members = ["minec"];
		};
		kvm = {
			members = ["minec"];
		};
	};

	environment.etc = {
		"modules-load.d/kvmfr.conf".text = ''
			kvmfr
		'';
	};
	services = {
		keyd = {
			enable = true;
			keyboards.default = {
				ids = ["*"];
				settings.main = {
					"super+p" = "f13";
				};
			};
		};
		spice-vdagentd.enable = true;
		samba = {
			enable = true;
			openFirewall = true;
			settings = {
				global = {
					security = "user";
					"acl allow execute always" = "yes";
					"server min protocol" = "SMB3";
					"server max protocol" = "SMB3";
				};
				public = {
					path = "/media/Storage";
					browseable = "yes";
					"valid users" = "minec";
					"read only" = "no";
					"guest ok" = "no";
				};
			};
		};
	};

	services.samba-wsdd = {
		enable = true;
		openFirewall = true;
	};
	networking.firewall.allowPing = true;

    services.udev.extraRules = ''
      SUBSYSTEM=="kvmfr", OWNER="minec", GROUP="kvm", MODE="0600"
	  TAG=="seat", ENV{ID_FOR_SEAT}=="drm-pci-0000_2b_00_0", ENV{ID_SEAT}="seat1", TAG-="master-of-seat"
    '';

  	#systemd.tmpfiles.rules = ["f /dev/shm/looking-glass 0660 minec qemu-libvirtd -"];
}