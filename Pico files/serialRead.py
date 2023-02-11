# type:ignore
# ---------- Packages ----------
import machine


# ---------- Functions ----------
def setupSerial():
    global uart
    # Setup serial
    uart = machine.UART(0, baudrate=9600)
    uart.init(baudrate=9600, bits=8, parity=None, stop=1)


# ---------- Main ----------
def main():
    buffer = ""
    setupSerial()
    while True:
        if uart.any():
            buffer += uart.read().decode()
            if "\\end\\" in buffer:
                if "\\start\\" in buffer:
                    data = buffer.replace("\\start\\","").replace("\\end\\","")
                    print(data)
                else:
                    print("Corrupted data")
                buffer = ""

main()