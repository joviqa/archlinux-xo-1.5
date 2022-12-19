\ Open Firmware boot script
dcon-unfreeze
" rw root=LABEL=ARCHroot rootdelay=10" to boot-file
" ext:\boot\vmlinuz-linux-via-olpc" to boot-device
" ext:\boot\initramfs-linux-via-olpc.img" to ramdisk
boot
