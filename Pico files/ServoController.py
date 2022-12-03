import machine
from time import sleep


led= machine.Pin(25, machine.Pin.OUT)
servoPin = 1

angleRange = 225
digitalRange = 180

currentPosition = 0


def degreesToAnalog(degrees):
    analog = round((degrees * 8000 / 225 + 1000) / 50) * 50
    return analog

def analogToDegrees(analog):
    degrees = round((analog - 1000) * 225 / 8000)
    return degrees

def turnAnalog(position):
    global servoPin
    servo = machine.PWM(machine.Pin(servoPin))
    servo.freq(50)
    global currentPosition
    currentPosition = degreesToAnalog(min(max(analogToDegrees(position), 0), digitalRange - 1))
    servo.duty_u16(currentPosition)
    print(currentPosition)
    print(analogToDegrees(currentPosition))

def turn(degrees):
    position = degreesToAnalog(degrees)
    turnAnalog(position)

def left():
    turn(0)
    
def right():
    turn(angleRange - 1)

def inc(degrees):
    servo = machine.PWM(machine.Pin(servoPin))
    servo.freq(50)
    global currentPosition
    currentPosition = degreesToAnalog(analogToDegrees(currentPosition) + degrees)
    turnAnalog(currentPosition)

def dec(degrees):
    servo = machine.PWM(machine.Pin(servoPin))
    servo.freq(50)
    global currentPosition
    currentPosition = degreesToAnalog(analogToDegrees(currentPosition) - degrees)
    turnAnalog(currentPosition)
    
    
turn(currentPosition)