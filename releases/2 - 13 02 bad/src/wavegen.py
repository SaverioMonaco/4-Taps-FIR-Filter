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
