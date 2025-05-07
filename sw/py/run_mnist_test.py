import mmap
import os
import struct
import sys
# === CONFIGURE YOUR ADDRESS INFO HERE ===
DMA_REG_BASE_ADDR = 0xA0030000
CTRL_REG_BASE_ADDR = 0xA0020000  
AXIL_RANGE     = 0x1000      # size of your register map (e.g., 4K)
IMAGE_SIZE     = 28*28
DMA_START_ADDR   = 0x60000000
DMA_DDR_SIZE     = 0x20000000
# === OPEN /dev/mem ===
fd = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)

# === MEMORY MAP AXI REGION ===
dma_reg = mmap.mmap(fd, AXIL_RANGE, mmap.MAP_SHARED,
                mmap.PROT_READ | mmap.PROT_WRITE,
                offset=DMA_REG_BASE_ADDR)
                
ddr_mem = mmap.mmap(fd, DMA_DDR_SIZE, mmap.MAP_SHARED,
                mmap.PROT_WRITE, offset=DMA_START_ADDR)
                
ctrl_reg = mmap.mmap(fd, AXIL_RANGE, mmap.MAP_SHARED,
                mmap.PROT_READ | mmap.PROT_WRITE,
                offset=CTRL_REG_BASE_ADDR)                
def write_reg(mem,reg_index, value):
    """Write a 32-bit value to the AXI register at the given offset"""
    mem.seek(reg_index*4)
    mem.write(struct.pack("<I", value))  # little-endian 32-bit

def read_reg(mem,reg_index):
    """Read a 32-bit value from the AXI register at the given offset"""
    mem.seek(offset*4)
    data = mem.read(4)
    return struct.unpack("<I", data)[0]

# === TEST: Write and Read a Register ===
#

with open(sys.argv[1], "rb") as f:
    data = f.read()
    ddr_mem.write(data)
    
write_reg(ctrl_reg,0, 0x0)
write_reg(ctrl_reg,0, 0x1)
write_reg(dma_reg,5, DMA_START_ADDR)
write_reg(dma_reg,6, 0x00000000)
write_reg(dma_reg,7, IMAGE_SIZE)
write_reg(dma_reg,4, 0x1)
write_reg(dma_reg,4, 0x0)

# === CLEAN UP ===
dma_reg.close()
ddr_mem.close()
ctrl_reg.close()
os.close(fd)

