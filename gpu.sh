#!/bin/bash
#Comment
#More Echos
#Fix logout crash
#Add exceptions to on/off to avoid freezing
boot() {
    sleep 5
    if $(lspci -H1 | grep --quiet NVIDIA)
    then
        off
        sleep 1
    fi
    on
    sleep 1
    off
    echo "0000:00:03.0" > /sys/bus/pci/devices/0000\:00\:03.0/driver/unbind 
    echo 0x8086 0x0c0c > /sys/bus/pci/drivers/vfio-pci/new_id
#   echo 0x8086 0x0416 > /sys/bus/pci/drivers/vfio-pci/new_id
}
 
vfio() {
    if ! $(lspci -H1 | grep --quiet NVIDIA)
    then
        on
        sleep 1
    fi
    unbind
    echo 0x10de 0x0ff6 > /sys/bus/pci/drivers/vfio-pci/new_id
    echo 0x10de 0x0e1b > /sys/bus/pci/drivers/vfio-pci/new_id
    echo 1 > /sys/bus/pci/rescan
}

nouveau() {
    if ! $(lspci -H1 | grep --quiet NVIDIA)
    then
        on
        sleep 1
    fi
    unbind
    echo 0x10de 0x0ff6 > /sys/bus/pci/drivers/nouveau/new_id
    echo "0000:01:00.1" > /sys/bus/pci/drivers/snd_hda_intel/bind
    echo 1 > /sys/bus/pci/rescan
}
 
nvidia() {
    if ! $(lspci -H1 | grep --quiet NVIDIA)
    then
        on
        sleep 1
    fi
    unbind
    echo 0x10de 0x0ff6 > /sys/bus/pci/drivers/nvidia/new_id
    echo "0000:01:00.1" > /sys/bus/pci/drivers/snd_hda_intel/bind
    echo 1 > /sys/bus/pci/rescan
}
 
unbind() {
    if [ -f /sys/bus/pci/devices/0000\:01\:00.0/driver/unbind ]
    then
        echo "0000:01:00.0" > /sys/bus/pci/devices/0000\:01\:00.0/driver/unbind
    fi
    if [ -f /sys/bus/pci/devices/0000\:01\:00.1/driver/unbind ]
    then
        echo "0000:01:00.1" > /sys/bus/pci/devices/0000\:01\:00.1/driver/unbind
    fi
}
 
on() {
    echo '\_SB_.PCI0.PEG0.PEGP._ON' > /proc/acpi/call
    if [ -f /sys/bus/pci/devices/0000\:01\:00.0/remove ]
    then
        echo 1 > /sys/bus/pci/devices/0000\:01\:00.0/remove
    fi
    if [ -f /sys/bus/pci/devices/0000\:01\:00.1/remove ]
    then
        echo 1 > /sys/bus/pci/devices/0000\:01\:00.1/remove
    fi
    echo 1 > /sys/bus/pci/rescan
}

off() {
    unbind
    echo '\_SB_.PCI0.PEG0.PEGP._OFF' > /proc/acpi/call
}
 
case "$1" in
    boot)
        boot
        ;;
    vfio)
        vfio
        ;;
    nouveau)
        nouveau
        ;;
    nvidia)
        nvidia
        ;;
    unbind)
        unbind
        ;;
    on)
        on
        ;;
    off)
        off
        ;;
esac
