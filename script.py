import serial

ser = serial.Serial('/dev/ttyUSB21', baudrate=115200) # open serial port
print(ser.name) # check which port was really used

def to_2(num):
    if num <= 127:
        return num
    elif num > 127:
        return num - 256

with open("signal.txt") as f, open("output.txt", "w") as out:
    signal = [int(line.rstrip()) for line in f]

    for sig in signal:
        ser.write(chr(sig))

        d = ord(ser.read())
        print(to_2(d))
        res = str(to_2(d))
        out.write(res + '\n')

    f.close()
    out.close()
ser.close() # close port
