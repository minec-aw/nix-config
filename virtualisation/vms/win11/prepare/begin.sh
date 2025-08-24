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