#!/usr/bin/env python3
import os
import argparse
from PIL import Image

input_folder = "input_images"
output_folder = "output_images"

os.makedirs(output_folder, exist_ok=True)

parser = argparse.ArgumentParser()

parser.add_argument("--resize", nargs=2, type=int)
parser.add_argument("--rotate", type=int)

args = parser.parse_args()

for filename in os.listdir(input_folder):
    if filename.lower().endswith(".jpg"):
        input_path = os.path.join(input_folder, filename)

        img = Image.open(input_path)

        if args.rotate:
            img = img.rotate(args.rotate)

        if args.resize:
            width, height = args.resize
            img = img.resize((width, height))

        name, ext = os.path.splitext(filename)

        suffix = ""

        if args.rotate:
            suffix += f"_rot{args.rotate}"

        if args.resize:
            suffix += f"_res{args.resize[0]}x{args.resize[1]}"

        output_filename = f"{name}{suffix}{ext}"
        output_path = os.path.join(output_folder, output_filename)

        img.save(output_path)

        print(f"Processed {filename}")

print("Done.")