from PIL import Image
import struct, sys

DB16 = b'\x14\x0c\x1c\x44\x24\x34\x30\x34\x6d\x4e\x4a\x4e\x85\x4c\x30\x34\x65\x24\xd0\x46\x48\x75\x71\x61\x59\x7d\xce\xd2\x7d\x2c\x85\x95\xa1\x6d\xaa\x2c\xd2\xaa\x99\x6d\xc2\xca\xda\xd4\x5e\xde\xee\xd6'
Sweetie16 = b'\x1a\x1c\x2c\x5d\x27\x5d\xb1\x3e\x53\xef\x7d\x57\xff\xcd\x75\xa7\xf0\x70\x38\xb7\x64\x25\x71\x79\x29\x36\x6f\x3b\x5d\xc9\x41\xa6\xf6\x73\xef\xf7\xf4\xf4\xf4\x94\xb0\xc2\x56\x6c\x86\x33\x3c\x57'

cover_img = Image.new("P",(240,136))

cover_img.putpalette(DB16)

palette = DB16
# print("initial",repr(palette))
manual_palette = False
has_cover = False

with open(sys.argv[1],"rb") as f:
    cart = bytearray(f.read())

def peek4(content,address):
    return (content[address>>1]>>((address&1)<<2))&15

i = 0
while i<len(cart):
    chunk_byte = cart[i]
    chunk_type = chunk_byte&31
    bank = (chunk_byte>>5)&7
    i+=1
    size = struct.unpack_from("<H",cart,i)[0]
    i+=3 # 2-byte size short plus reserved byte
    if chunk_type==5 or chunk_type==19:
        if size==0: size=65536
    if bank==0:
        if chunk_type==12: # CHUNK_PALETTE
            palette = b''.join(struct.unpack_from('48c',cart,i))
            cover_img.putpalette(palette)
            # print("chunk_palette",repr(palette))
            manual_palette = True
        elif chunk_type==17 and not manual_palette: # CHUNK_DEFAULT
            palette = Sweetie16
            cover_img.putpalette(palette)
            # print("chunk_default",repr(palette))
        elif chunk_type==18:
            has_cover = True
            ts = size
            if ts<16320: ts=16320
            screen = bytearray(b''.join(struct.unpack_from(str(ts)+'c',cart,i)))
            for j in range(240*136):
                xy = (j%240,j//240)
                cover_img.putpixel(xy,peek4(screen,j))
    if chunk_type==3:
        raw_gif = b''.join(struct.unpack_from(str(size)+'c',cart,i))
        with open(sys.argv[2],"wb") as f:
            f.write(raw_gif)
        sys.exit(0)
    i+=size

if has_cover:
    # print("final",repr(palette))
    cover_img.putpalette(palette)
    cover_img.save(sys.argv[2])