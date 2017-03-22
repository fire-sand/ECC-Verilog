import sys

WIDTH = 256

def shift_add(x, y):
    a = 0
    b = x
    q = y
    for i in xrange(WIDTH):
        carry = 0

        if (q & 1) == 1:
            a = a + b
            carry = a >> 256
            a = a & (pow(2, WIDTH) - 1)

        q = ((a & 1) << (WIDTH - 1)) | ((q >> 1) & (pow(2, WIDTH) - 1))
        a = ((carry << 255) | (a >> 1)) & (pow(2, WIDTH) - 1)

        print hex(a), hex(q)

    print hex(a), hex(q)

x = 0x87cf9d3a33d4ba65270b4898643d42c2cf932dc6fb8c0e192fbc93c6f58c3b72
y = 0x87cf9d3a33d4ba65270b4898643d42c2cf932dc6fb8c0e192fbc93c6f58c3b72
shift_add(x, y)

print hex(x * y), (x*y).bit_length()
