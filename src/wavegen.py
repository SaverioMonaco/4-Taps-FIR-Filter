def signed_to_unsigned(signed):
    if(signed>=0):
        return signed
    else:
        return 2**8+signed


def unsigned_to_signed(unsigned):
    if(unsigned<2**7):
        return unsigned
    else:
        return unsigned-2**8


def int_to_char(value):
    return chr(signed_to_unsigend(value))


def char_to_int(character):
    return unsigned_to_signed(ord(character))

import serial
ser = serial.Serial('/dev/ttyUSB21', baudrate=115200)

# Let's load the array from the file 'input.txt'
file = open('./src/input.txt', 'r')

for i in range(100):
    sig = int(file.readline())
    ser.write(int_to_char(sig))
    d = ser.read()
    #print("Output:", ord(d))
    print(char_to_int(d))
