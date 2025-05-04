import mmap
import os
import struct

PHYS_ADDR = 0x60000000  # DMA buffer physical address
MAP_SIZE  = 0x20000000  # 512 MB
NUM_WORDS = 1024        # Number of 16-bit values to read
WORD_SIZE = 2           # Each value is 2 bytes (uint16)

# Open /dev/mem for read access
with open("/dev/mem", "rb") as f:
    # Memory-map the DMA region
    mem = mmap.mmap(f.fileno(), MAP_SIZE, mmap.MAP_SHARED,
                    mmap.PROT_READ, offset=PHYS_ADDR)

    # Read raw bytes
    raw_data = mem.read(NUM_WORDS * WORD_SIZE)

    # Interpret as unsigned 16-bit integers (little-endian)
    uint16_list = list(struct.unpack('<' + 'H' * NUM_WORDS, raw_data))

    # Save to binary file
    with open("dma_output.bin", "wb") as bin_file:
        bin_file.write(raw_data)

    # Save to human-readable text file
    with open("dma_output.txt", "w") as txt_file:
        for val in uint16_list:
            txt_file.write(f"{val}\n")

    mem.close()
