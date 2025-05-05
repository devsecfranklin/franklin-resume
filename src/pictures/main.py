"""Module docstring."""

from imagededup.methods import PHash
from imagededup.utils import plot_duplicates  # find duplicates

IMAGE_DIR = "/home/franklin/Pictures"

phasher = PHash()

# Generate encodings for all images in an image directory
encodings = phasher.encode_images(image_dir=IMAGE_DIR)

# Find duplicates using the generated encodings
duplicates = phasher.find_duplicates(encoding_map=encodings)

# plot duplicates obtained for a given file using the duplicates dictionary


plot_duplicates(image_dir=IMAGE_DIR, duplicate_map=duplicates, filename="/me/389.jpg")
