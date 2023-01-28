import utime
import machine

uart = machine.UART(0, baudrate=9600)
uart.init(baudrate=9600, bits=8, parity=None, stop=1)

i = 0
while True:
 uart.write(str(i))
 uart.write("\\end\\")
 
 print('data sent', str(i))
 i+=1
 
 utime.sleep(1) # Wait 10 seconds