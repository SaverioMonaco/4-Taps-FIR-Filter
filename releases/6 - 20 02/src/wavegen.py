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

print("conversion functions imported")

import serial
ser = serial.Serial('/dev/ttyUSB21', baudrate=115200)

# Creating a square wave
a = False
for i in range(200):
    if(a):
        ser.write(120)
        #print("Input: 120")
    if(not a):
        ser.write(20)
        #print("Input: 20")
    if(i % 10 == 0):
        a = not a
    d = ser.read()
    #print("Output:", ord(d))
    print(ord(d))
