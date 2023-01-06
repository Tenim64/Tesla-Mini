from machine import Pin,PWM
from time import sleep
 
A_1A_pin = 26                 # Motor drive module
A_1B_pin = 27                 # Motor drive module
 
def setup():
    global A_1A
    global A_1B
    
    A_1A = PWM(Pin(A_1A_pin))
    A_1B = PWM(Pin(A_1B_pin))
    A_1A.freq(1000)             # Set the driver operating frequency to 1K
    A_1B.freq(1000)             # Set the driver operating frequency to 1K
 
def main():
    setup()
    direction = 1
    while True:
        for Percentage in range(0,100, 1):
            drive(Percentage, direction)
            sleep(0.1)
        for Percentage in range(100,0, -1):
            drive(Percentage, direction)
            sleep(0.1)
        direction = -1

def drive(speedPercentage, direction):
    speedValue = round(speedPercentage * 65535 / 100)
    print(speedValue, ' in ', direction)
    if direction > 1:
        A_1B.duty_u16(0)                      # control fan speed
        A_1A.duty_u16(speedValue)             # control fan speed
    if direction < 0:
        A_1A.duty_u16(0)                      # control fan speed
        A_1B.duty_u16(speedValue)             # control fan speed

def a(x):
    A_1A.duty_u16(x)

def b(x):
    A_1B.duty_u16(x)

def fo():
    a(65535)
    b(0)

def ba():
    a(0)
    b(65535)

def st():
    a(0)
    b(0)

main()