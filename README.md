# Accessing GRUB in an emergency situation
A guide for my future self


## The problem
<b>The NVRAM in this system (Lenovo Y50-70 Touch 80DT, August 2015) has entered a read-only state.</b>

See [this writeup](https://www.dedoimedo.com/computers/lenovo-g50-read-only-nvram.html) on another Lenovo user's virtually identical situation.

This system cannot boot from USB, the boot order cannot be changed, and the existing path to grub2 cannot be modified.

- The EFI entry that is attempting to load is `ubuntu`.
- This entry is searching for `/EFI/ubuntu/shimx64.efi`.
- The file `/EFI/ubuntu/grubx64.efi` must also be present to enter rescue mode.

Emergency copies of these files are available under `emergency-bootloader` in the Windows home folder.
They were downloaded from [this Stack Exchange response](https://askubuntu.com/a/597381), but can also be obtained from an Ubuntu ISO with a little work.

## Steps to fix
Open an elevated command prompt and run the following:
```
diskpart
select disk 0
select partition 2
assign letter=z
^C
z:
cd EFI
cd ubuntu
copy "c:\Users\corey\emergency-bootloader\shimx64.efi" .
copy "c:\Users\corey\emergency-bootloader\grubx64.efi"
```

If you need to repair your Linux installation, prepare an Ubuntu Live USB now. This must be Ubuntu or a distro built upon Ubuntu.

Upon reboot, you will enter a rescue prompt with limited functionality. Run the following to boot from your USB, replacing `(hd0,1)` with the root of the USB device: 

```
set root=(hd0,1)
linux /casper/vmlinuz.efi boot=casper quiet splash
initrd /casper/initrd.lz
boot
```

Ubuntu should then boot successfully. Upon install, Ubuntu will reconstruct the Grub bootloader, at which point you can add custom entries to access Linux distributions on separate partitions. These must be accessed through the Ubuntu bootloader due to the NVRAM failure.

## Extras
### Booting a Windows installation USB
This requires a full GRUB install; the rescue prompt is not sufficient.

```
insmod ntfs
set root=(hd0,msdos1)
chainloader (${root})/EFI/Microsoft/Boot/bootmgfw.efi
boot
```

### Booting GParted Live from disk partition
```
set root=(hd0,8)
linux /live-hd/vmlinuz boot=live config union=overlay username=user components noswap noeject vga=788 ip= net.ifnames=0 live-media-path=/live-hd bootfrom=/dev/sda8 toram=filesystem.squashfs
initrd /live-hd/initrd.img
boot
```

## Notes
<b>NEVER move, resize, reformat or delete Partition 2 (EFI) on this hard drive.</b>

The boot partition must always be Partition 2. 

The UUID of Partition 2 must be: `99e8c7d7-50eb-485b-bba1-5f969009fb78`

If the UUID needs to be reset, run the following:
```
sudo tune2fs /dev/sda2 -U 99e8c7d7-50eb-485b-bba1-5f969009fb78
```

If the firmware cannot recognize the EFI partition, a PXE boot will be required to access files on the disk. If the ethernet card were to then fail, the system would require motherboard replacement.

### Emergency EFI netboot using Ubuntu

Follow [this guide](https://wiki.ubuntu.com/UEFI/PXE-netboot-install) with a few modifications. 

1. Set the contents of of `/etc/dnsmasq.conf` to the following:

```
interface=enp9s0
bind-interfaces
dhcp-range=192.168.0.55,192.168.0.55
dhcp-boot=grubnetx64.efi.signed
dhcp-option-force=66,192.168.0.1
enable-tftp
tftp-root=/srv/tftp/
```

2. Run these commands before starting the `dnsmasq` service:
```
ip link set enp9s0 up
ip addr add 192.168.0.1/24 dev enp9s0
```

#### Corey Rowe, November 2017
