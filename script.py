import serial
import os

ser = serial.Serial('/dev/ttyUSB21', baudrate=115200) # open serial port
print(ser.name) # check which port was really used

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


with open("signal.txt") as f, open("output.txt", "w") as out:
    signal = [int(line.rstrip()) for line in f]

    for sig in signal:
        ser.write(int_to_char(sig))

        d = ser.read()
        res = char_to_int(d)
        print(res)
        out.write(str(res) + '\n' )

    f.close()
    out.close()
ser.close() # close port

os.system('./upload.sh')
