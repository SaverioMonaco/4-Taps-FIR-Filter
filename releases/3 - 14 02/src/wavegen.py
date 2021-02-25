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

signal = [142,156,119,123,128,104,117,85,91,74,54,50,55,48,47,51,68,57,74,78,89,93,104,97,125,132,133,158,156,151,115,135,140,139,122,102,103,94,80,75,71,46,52,62,63,56,69,71,71,89,75,87,115,132,137,139,134,129,158,166,149,153,127,146,127,123,108,96,71,59,58,51,38,61,41,46,72,53,80,80,82,94,96,95,131,131,147,145,140,181,157,149,136,131,115,94,101,94,69,81,78,64,45,56,46,52,60,62,80,90,81,111,117,119,128,154,134,155,152,159,141,148,140,130,134,95,104,110,90,61,56,71,61,65,38,51,58,77,73,77,90,77,91,123,143,134,153,145,133,157,144,140,136,107,125,131,100,87,62,78,48,200]
# Creating a square wave
a = False
for i in range(200):
    ser.write(signal[i])
    d = ser.read()
    #print("Output:", ord(d))
    print(ord(d))
