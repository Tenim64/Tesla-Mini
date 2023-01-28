import machine

uart = machine.UART(0, baudrate=9600)
uart.init(baudrate=9600, bits=8, parity=None, stop=1)

while True:
    if uart.any()
        buffer += uart.read().decode()
        if "\\end\\" in buffer:
            print(buffer.replace("\\end\\",""))
            buffer = ""