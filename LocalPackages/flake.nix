{
	description = "organically procured packages";
	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
	};
	outputs = { self, nixpkgs }:
	let 
		callPackage = nixpkgs.legacyPackages.x86_64-linux.callPackage;
		pythonCallPackage = nixpkgs.legacyPackages.x86_64-linux.python313Packages.callPackage;
		mkHyprlandPlugin = nixpkgs.legacyPackages.x86_64-linux.hyprlandPlugins.mkHyprlandPlugin;
	in
	{
		tilp = callPackage ./tilp {};
		openssl = callPackage ./openssl {};
		macos-hyprcursor = callPackage ./macos-hyprcursor {};
		wayfire-round-corners = pythonCallPackage ./wayfire-round-corners {};
		csd-titlebar-move = callPackage ./hyprcsd { inherit mkHyprlandPlugin; };
		hyprfreeze = nixpkgs.legacyPackages.x86_64-linux.writeShellScriptBin "hyprfreeze" (builtins.readFile ./hyprfreeze);
		nvidia-bind-vfio = nixpkgs.legacyPackages.x86_64-linux.writeShellScriptBin "nvidia-bind-vfio" ''
			#!/run/current-system/sw/bin/bash
			# Commence a pci-rescan to make any sleeping nvidia stuff wake up again
			echo 1 | tee /sys/bus/pci/rescan
			sleep 1

			# Kill all processes ran on the nvidia GPU
			gpu_pids=$(lsof /dev/nvidia* | awk 'NR!=1 {print $2}')
			for pid in $gpu_pids; do
				kill -9 $pid
			done 
			gpu_pids2=$(lsof $(realpath /dev/dri/by-path/pci-0000\:01\:00.0-render) | awk 'NR!=1 {print $2}')
			for pid in $gpu_pids2; do
				kill -9 $pid
			done 
			gpu_pids3=$(lsof $(realpath /dev/dri/by-path/pci-0000\:01\:00.0-card) | awk 'NR!=1 {print $2}')
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
		nvidia-unbind-vfio = nixpkgs.legacyPackages.x86_64-linux.writeShellScriptBin "nvidia-unbind-vfio" ''
			#!/run/current-system/sw/bin/bash

			modprobe -r vfio_pci
			modprobe -r vfio_iommu_type1
			modprobe -r vfio

			#virsh nodedev-reattach pci_0000_01_00_0 
			#virsh nodedev-reattach pci_0000_01_00_1

			modprobe nvidia_drm "modeset=1"
			modprobe nvidia_modeset
			modprobe nvidia_uvm
			modprobe nvidia "NVreg_DynamicPowerManagement=0x03"
			sleep 1
			#systemctl start nvidia-powerd.service

			echo 1 | tee /sys/bus/pci/devices/0000:01:00.1/remove
		'';
	};
}