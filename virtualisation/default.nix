{ config, lib, pkgs, modulesPath, ... }:
{
	boot = {
		blacklistedKernelModules = [ "nvidia" "nouveau" "nvidia_drm" "nvidia_uvm" "nvidia_modeset" ]; ##passthrough stuff
		kernelModules = ["vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio"]; ##passthrough stuff
		extraModprobeConfig = "options vfio-pci ids=10de:2504,10de:228e";
		kernelParams = ["intel_iommu=on" "iommu=pt" "vfio_iommu_type1.allow_unsafe_interrupts=1" "kvm.ignore_msrs=1" "vfio-pci.ids=10de:2504,10de:228e" "kvmfr.static_size_mb=128"];
		initrd.kernelModules = [ "kvmfr" ];
		extraModulePackages = with config.boot.kernelPackages; [
			kvmfr #(pkgs.callPackage ../LocalPackages/kvmfr { inherit kernel;})
		];
	};
	virtualisation = {
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
				];
			};
           in
           [ env ];

    	preStart =
		''
		mkdir -p /var/lib/libvirt/hooks

		cp -r -f ${./qemu} /var/lib/libvirt/hooks/qemu
		cp -r -f ${./vms} /var/lib/libvirt/hooks/vms
		chmod +x /var/lib/libvirt/hooks/qemu
		chmod -R +x /var/lib/libvirt/hooks/vms
		'';
	};
	security.sudo.extraRules = [
		{
			groups = ["libvirtd"];
			commands = [
				{
					command = "${./vms/win11/release/end.sh}"; 
					options = ["NOPASSWD"];
				}
				{
					command = "${./vms/win11/prepare/begin.sh}"; 
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

	services.spice-vdagentd.enable = true;

    services.udev.extraRules = ''
      SUBSYSTEM=="kvmfr", OWNER="minec", GROUP="kvm", MODE="0600"
    '';

  	#systemd.tmpfiles.rules = ["f /dev/shm/looking-glass 0660 minec qemu-libvirtd -"];
}