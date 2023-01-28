# type:ignore
# ---------- Packages ----------
import utime
import machine


# ---------- Functions ----------
def setupSerial():
    # Setup serial
    uart = machine.UART(0, baudrate=9600)
    uart.init(baudrate=9600, bits=8, parity=None, stop=1)

def sendSerial(data):
    # Write that this the start of the data packet
    uart.write("\\start\\")
    # Write data to serial
    uart.write(data)
    # Write that this the end of the data packet
    uart.write("\\end\\")

    print('data sent', data)


# ---------- Main ----------
def main():
    # Loop count
    i = 0
    # Continuously send data
    while True:
        # Send data
        sendSerial(str(i))
        
        # Increase loop count
        i+=1

        # Wait 1 seconds
        utime.sleep(1)

main()