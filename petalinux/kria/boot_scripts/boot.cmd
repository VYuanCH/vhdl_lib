setenv bootargs console=ttyPS0,115200 root=/dev/mmcblk0p2 rw rootwait clk_ignore_unused mem=1532M memmap=512M$0x60000000

fatload mmc 1 0x10000000 system.bit
fpga load 0 0x10000000 ${filesize}

fatload mmc 1 0x20000000 image.ub
fatload mmc 1 0x18000000 system.dtb
bootm 0x20000000 - 0x18000000
