import os
import struct
from tensorflow.keras.datasets import mnist

# Load MNIST data
(x_train, y_train), (_, _) = mnist.load_data()

# Number of images to save
NUM_IMAGES = 100
output_dir = "mnist_bin"
os.makedirs(output_dir, exist_ok=True)

for i in range(NUM_IMAGES):
    img = x_train[i]         # shape: (28, 28)
    label = y_train[i]
    
    # Flatten to row-major 1D array
    flat = img.reshape(-1, 784).astype('uint16')
    flat = (flat/32).astype('uint16')
    if i==0:
        print(flat)
    

    # Save as .bin file
    filename = f"{label}_{i:03d}.bin"
    with open(os.path.join(output_dir, filename), "wb") as f:
        f.write(flat.tobytes())

print(f"{NUM_IMAGES} uncompressed MNIST images saved to '{output_dir}/' as 784-byte .bin files.")

