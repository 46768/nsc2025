from PIL import Image
import numpy as np
import sys

if len(sys.argv) != 5:
    print("required argument: [og_img_path] [og_PixelxPixel] "
          + "[rescaled_img] [rescaled_PixelxPixel]")
    exit(1)

og_img_path = sys.argv[1]
og_pxp = int(sys.argv[2])

rescaled_img_path = sys.argv[3]
rescaled_pxp = int(sys.argv[4])

og_img = Image.open(og_img_path)
og_pixel_array = np.asarray(og_img)

single_pixel_array = og_pixel_array[::og_pxp, ::og_pxp]

rescaled_pixel_array = np.repeat(single_pixel_array, rescaled_pxp, axis=0)
rescaled_pixel_array = np.repeat(rescaled_pixel_array, rescaled_pxp, axis=1)

rescaled_img = Image.fromarray(rescaled_pixel_array, mode="RGBA")
rescaled_img.save(rescaled_img_path)

og_img.close()
rescaled_img.close()
