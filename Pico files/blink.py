import os
import sys
import gc
gc.collect()
gc.mem_free()

import machine
import time

led = machine.Pin("LED",machine.Pin.OUT)
led.off()
led.on()

print(os.uname())

while True:
    led.toggle()
    time.sleep(0.5)