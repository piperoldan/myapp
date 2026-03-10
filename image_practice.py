#!/usr/bin/env python3

import os
import argparse
from PIL import Image

INPUT_FOLDER = "input_images"
OUTPUT_FOLDER = "output_images"
SUPPORTED_FORMATS = (".jpg", ".jpeg", ".png", ".webp")


def main():
    parser = argparse.ArgumentParser(description="Process images with Pillow")
    parser.add_argument("--resize", nargs=2, type=int, metavar=("WIDTH", "HEIGHT"))
    parser.add_argument("--rotate", type=int, help="Rotate counter-clockwise")
    parser.add_argument("--format", type=str, help="Output format: jpg, jpeg, png, webp")
    args = parser.parse_args()

    os.makedirs(OUTPUT_FOLDER, exist_ok=True)

    for filename in os.listdir(INPUT_FOLDER):
        if not filename.lower().endswith(SUPPORTED_FORMATS):
            continue

        input_path = os.path.join(INPUT_FOLDER, filename)
        img = Image.open(input_path)

        name, ext = os.path.splitext(filename)
        suffix = ""

        if args.rotate is not None:
            img = img.rotate(args.rotate)
            suffix += f"_rot{args.rotate}"

        if args.resize:
            width, height = args.resize
            img = img.resize((width, height))
            suffix += f"_res{width}x{height}"

        if args.format:
            ext = "." + args.format.lower()

        if ext in (".jpg", ".jpeg"):
            img = img.convert("RGB")

        output_filename = f"{name}{suffix}{ext}"
        output_path = os.path.join(OUTPUT_FOLDER, output_filename)

        img.save(output_path)
        print(f"Processed {filename} -> {output_filename}")

    print("Done.")


if __name__ == "__main__":
    main()