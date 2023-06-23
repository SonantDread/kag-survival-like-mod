from PIL import Image, ImageDraw
import os
# for world.png
def label_image(image_path):
    # Open the image
    image = Image.open(image_path).convert("RGBA")

    width, height = image.size

    # Create a new image with the enlarged size for labeling
    enlarged_size = (width * 4, height * 4)
    enlarged_image = image.resize(enlarged_size)

    # Create a new image with the labels
    labeled_image = Image.new("RGBA", enlarged_size, (255, 255, 255, 0))
    labeled_image.paste(enlarged_image, (0, 0), enlarged_image)

    draw = ImageDraw.Draw(labeled_image)

    # Label each 8x8 block with a number
    label = 0
    size = 1 # change this if your image is larger than 8x8 pixel per object
    size = size * 32
    for y in range(0, enlarged_size[1], size):
        for x in range(0, enlarged_size[0], size):
            # Determine the coordinates of the current block
            left = x
            top = y
            right = x + size
            bottom = y + size

            # Get the background color of the block
            background_color = enlarged_image.getpixel((left, top))

            # Calculate the inverted color for the numbers
            inverted_color = tuple(255 - value for value in background_color[:3]) + (255,)

            # Draw a rectangle on the labeled image
            draw.rectangle([(left, top), (right, bottom)], outline="black")

            # Label the block with an inverted number
            label_str = str(label)
            label_width, label_height = draw.textsize(label_str)
            label_position = (left + (size - label_width) // 2, top + (size - label_height) // 2)
            draw.text(label_position, label_str, fill=inverted_color)

            # Increment the label
            label += 1

    # Show the labeled image
    labeled_image.show()

# Path to the input image
image_path = os.getcwd() + "/Materials/Materials.png"

# Label the image
label_image(image_path)
