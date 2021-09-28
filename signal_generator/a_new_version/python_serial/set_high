import serial
def set_high()
    com = serial.Serial('COM5', 9600)
    print(com)
    success_bytes = com.write(chr(0x01).encode("utf-8"))
    print(success_bytes)
    print(com.read().hex())