from PIL import Image

def main():
    # parameters
    image = "vader.png"  # path to the image
    SIZE        = (64, 64)      # width, height
    THRESHOLD   = 150           # 0–255: below → 1, above → 0

    img = Image.open(image).convert("L").resize(SIZE, Image.BICUBIC)
    bw  = img.point(lambda x: 1 if x < THRESHOLD else 0, mode="1")

    lines = []
    for y in range(bw.height):
        row = "".join(str(bw.getpixel((x,y))) for x in range(bw.width))
        lines.append(f'"{row}"')

    print(f"type vader_bitmap_t is array(0 to {bw.height-1}) of std_logic_vector({bw.width-1} downto 0);")
    print("constant DARK_VADER_BITMAP : vader_bitmap_t := (")
    for l in lines[:-1]:
        print("  " + l + ",")
    print("  " + lines[-1])
    print(");")
    
if __name__ == "__main__":
    main()