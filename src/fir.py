import serial
import math
ser = serial.Serial('/dev/ttyUSB21', baudrate=115200)

# Let's load the array from the file 'input.txt'
file_ou  = open('./src/input.txt', 'w')

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
    return chr(signed_to_unsigned(value))

def char_to_int(character):
    return unsigned_to_signed(ord(character))

sig_data = []

data_size = 200
noise = 1 # the higher the noisier
print("-------------------\nInput:")
for i in range(data_size):
    sig = int(40*(2*math.sin(i/10)+ noise))
    print(sig)
    noise = -noise
    sig_data.append(sig)

print("-------------------\nOutput:")
# wavegen
for i in range(data_size):
    ser.write(int_to_char(sig_data[i]))
    d = ser.read()
    print(char_to_int(d)*8)
    file_ou.write('%d\n' % 32*char_to_int(d))
