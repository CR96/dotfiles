# Restoring the Grub2 bootloader
A guide for my future self


## The problem
<b>The NVRAM in this system (Lenovo Y50-70 Touch 80DT, August 2015) has entered a read-only state.</b>

See [this writeup](https://www.dedoimedo.com/computers/lenovo-g50-read-only-nvram.html) on another Lenovo user's virtually identical situation.

This system cannot boot from USB, the boot order cannot be changed, and the existing path to grub2 cannot be modified.

- The EFI entry that is attempting to load is 'ubuntu'.
- This entry is searching for "/EFI/ubuntu/shimx64.efi".
- The file "/EFI/ubuntu/grubx64.efi" must also be present to enter rescue mode.

Emergency copies of these files are available under "Emergency EFIs" in the Windows home folder.
They were downloaded from [this Stack Exchange response](https://askubuntu.com/questions/597376), but can also be obtained from an Ubuntu ISO with a little work.

## Steps to fix
Open an elevated command prompt and run the following:
```
diskpart
select disk 0
select partition 2
assign letter=z
^C
z:
copy "c:\Users\corey\Emergency EFIs\shimx64.efi" .
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

## Notes
<b>NEVER move, resize, reformat or delete Partition 2 (EFI) on this hard drive.</b>
If the UUID of the EFI partition changes, the system will require motherboard replacement to boot.

#### Corey Rowe, November 2017
