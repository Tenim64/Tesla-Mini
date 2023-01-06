from time import sleep
import board
import pwmio
import sys
from adafruit_motor import motor
 
A_1A_pin = board.GP26
A_1B_pin = board.GP27
 
def setup():
    global motor
    
    A_1A = pwmio.PWMOut(A_1A_pin, frequency=50)
    A_1B = pwmio.PWMOut(A_1B_pin, frequency=50)
    motor = motor.DCMotor(A_1A, A_1B)
 
def main():
    print("Setup!")
    setup()
    print("Test!")
    direction = 1
    while True:
        for Percentage in range(10,100, 5):
            drive(Percentage, direction)
            sleep(0.3)
        drive(0, 0)
        sleep(2)
        for Percentage in range(100,10, -5):
            drive(Percentage, direction)
            sleep(0.3)
        drive(0, 0)
        direction *= -1

def drive(speedPercentage, direction):
    motor.throttle = speedPercentage / 100 * direction * -1
    print(motor.throttle * -1)

def fo():
    drive(100, 1)

def ba():
    drive(100, -1)

def st():
    drive(0, 0)

main()