import mmap
import os
import struct

# === CONFIGURE YOUR ADDRESS INFO HERE ===
AXIL_BASE_ADDR = 0xA0020000  # replace with your actual base address
AXIL_RANGE     = 0x1000      # size of your register map (e.g., 4K)

# === OPEN /dev/mem ===
fd = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)

# === MEMORY MAP AXI REGION ===
mem = mmap.mmap(fd, AXIL_RANGE, mmap.MAP_SHARED,
                mmap.PROT_READ | mmap.PROT_WRITE,
                offset=AXIL_BASE_ADDR)

def write_reg(offset, value):
    """Write a 32-bit value to the AXI register at the given offset"""
    mem.seek(offset)
    mem.write(struct.pack("<I", value))  # little-endian 32-bit

def read_reg(offset):
    """Read a 32-bit value from the AXI register at the given offset"""
    mem.seek(offset)
    data = mem.read(4)
    return struct.unpack("<I", data)[0]

# === TEST: Write and Read a Register ===
write_reg(0x00, 0x12345678)
val = read_reg(0x00)
print(f"Value read back: 0x{val:08X}")

# === CLEAN UP ===
mem.close()
os.close(fd)
