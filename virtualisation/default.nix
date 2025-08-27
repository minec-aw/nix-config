{ config, lib, pkgs, pkgs-mesa-pin, modulesPath, ... }:
let
	beginScript = pkgs.writeShellScriptBin "nvidia-bind-vfio" ''
#!/run/current-system/sw/bin/bash
# Commence a pci-rescan to make any sleeping nvidia stuff wake up again
echo 1 | tee /sys/bus/pci/rescan
sleep 1

# Kill all processes ran on the nvidia GPU
gpu_pids=$(lsof /dev/nvidia* | awk 'NR!=1 {print $2}')
for pid in $gpu_pids; do
	kill -9 $pid
done 
gpu_pids2=$(lsof $(realpath /dev/dri/by-path/pci-0000\:2b\:00.0-render) | awk 'NR!=1 {print $2}')
for pid in $gpu_pids2; do
	kill -9 $pid
done 
gpu_pids3=$(lsof $(realpath /dev/dri/by-path/pci-0000\:2b\:00.0-card) | awk 'NR!=1 {print $2}')
for pid in $gpu_pids3; do
	kill -9 $pid
done 

# Remove power systemd service
#systemctl stop nvidia-powerd.service

#Try to unload drivers 25 times
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25; do
	
	modprobe -r -a nvidia_drm nvidia_uvm nvidia_modeset nvidia
	if lsmod | grep -q nvidia; then
		if [ $i = 25 ]; then
			echo "Couldn't unmount the kernel modules in 25 attempts"
			exit 1
		fi
		sleep 0.25
		echo "Attempt #$i"
	else
		break
	fi
done

#virsh nodedev-detach pci_0000_01_00_0 
#virsh nodedev-detach pci_0000_01_00_1

modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1
'';
endScript = pkgs.writeShellScriptBin "nvidia-unbind-vfio" ''
#!/run/current-system/sw/bin/bash

modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

#virsh nodedev-reattach pci_0000_01_00_0 
#virsh nodedev-reattach pci_0000_01_00_1

modprobe nvidia_drm "modeset=1"
modprobe nvidia_modeset
modprobe nvidia_uvm
modprobe nvidia "NVreg_DynamicPowerManagement=0x02"
# This parameter is for power saving on laptops, you can just do modprobe nvidia
# if you are a desktop user
sleep 1
#systemctl start nvidia-powerd.service

echo 1 | tee /sys/bus/pci/devices/0000:2b:00.1/remove
# this is to remove audio through hdmi, to make power saving on laptops work
# you can remove this if you are not using a laptop
'';
in
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
		beginScript
		endScript
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

	services.samba = {
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

	services.samba-wsdd = {
		enable = true;
		openFirewall = true;
	};

	#networking.firewall.enable = lib.mkForce false;
	networking.firewall = {
		allowedTCPPorts = [ 111 2049 4000 4001 4002 20048 ];
    	allowedUDPPorts = [ 111 2049 4000 4001 4002 20048 ];
	};
	networking.firewall.allowPing = true;

    services.udev.extraRules = ''
      SUBSYSTEM=="kvmfr", OWNER="minec", GROUP="kvm", MODE="0600"
    '';

  	#systemd.tmpfiles.rules = ["f /dev/shm/looking-glass 0660 minec qemu-libvirtd -"];
}