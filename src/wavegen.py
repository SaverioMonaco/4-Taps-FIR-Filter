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
    return char(signed_to_unsigend(value))


def char_to_int(character):
    return unsigned_to_signed(ord(character))

import serial
ser = serial.Serial('/dev/ttyUSB21', baudrate=115200)

import math

data_size = 100
noise = 1 # the higher the noisier

for i in range(data_size):
    sig = 60*(math.sin(i/10)+ noise)
    noise = -noise
    inp = round(sig)
    ser.write(int(inp)) # we write it as an int
    d = ser.read()
    #print("Output:", ord(d))
    print(ord(d))
