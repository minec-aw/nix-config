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