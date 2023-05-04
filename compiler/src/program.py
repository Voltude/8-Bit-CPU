"""
This program makes use of the pySerial library.
The library can be installed with: pip install pyserial
"""

import serial
import sys
from time import sleep

BAUDRATE = 9600
NUM_ADDRESSES = 256
NUM_BYTES = NUM_ADDRESSES * 2

def read_file(filename):
    code = []
    with open(filename) as file:
        for line in file.readlines():
            line = line.strip()
            code.append(int(line, 2).to_bytes(2, 'big'))
        for _ in range(len(code), NUM_ADDRESSES):
            code.append(b'\x00\x00')
    return code

def begin(ser):
    print("Connected to {}".format(ser.name))
    ser.write(b'B') # Send start byte
    sleep(1./10)

def program(ser, code):
    print("Loading program:")
    for i, line in enumerate(code):
        ser.write(line)
        sleep(1./200)
        if i % 16 == 0:
            print('-', end='', flush=True)
    print()

# Reads and returns 512 bytes from serial
def read(ser):
    return ser.read(NUM_BYTES)

# Verify that the returned serial data matches the transmitted data
def verify(code, data):
    if b"".join(code) == data:
        print("Program verified")
    else:
        print("An error occurred while loading the program, please try again.")

def main():
    code = []
    data = bytes()
    ser = serial.Serial()
    ser.baudrate = BAUDRATE

    # Serial port and file must be specified
    if len(sys.argv) == 3:
        if sys.argv[1] in ["-h", "--help"]:
            print("Usage: {} <file>".format(sys.argv[0]))
            return
        
        # Assign the selected serial port
        ser.port = sys.argv[1]

        # Convert file into bytes
        code = read_file(sys.argv[2])

        try:
            ser.open()
            begin(ser)
            program(ser, code)
            data = read(ser)
            ser.close()
        except:
            print("Unable to open {}".format(ser.name))
        
        verify(code, data)
    else:
        print("Usage: {} <port> <file>".format(sys.argv[0]))

if __name__ == "__main__":
    main()