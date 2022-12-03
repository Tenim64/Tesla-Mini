# -------------------------- Servo controller -------------------------- 
# Packages
import machine
from time import sleep


# Variables
led= machine.Pin(25, machine.Pin.OUT)
servoPin = 1

angleRange = 225
digitalRange = 180

currentPosition = 90


# Functions
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
    

# Default position
turn(currentPosition)



# -------------------------- UDP receiver --------------------------
import usocket as socket
import network

nic = network.Driver(...)
if not nic.isconnected():
    nic.connect()
    print("Waiting for connection...")
    while not nic.isconnected():
        sleep(1)
print(nic.ifconfig())

quit()

UDP_IP = socket.getaddrinfo('0.0.0.0', 80)
UDP_PORT = 5005
print(UDP_IP)

sock = socket.socket(socket.AF_INET, # Internet
                     socket.SOCK_DGRAM) # UDP
sock.bind((UDP_IP, UDP_PORT))

while True:
    data, addr = sock.recvfrom(1024) # buffer size is 1024 bytes
    print("received message: %s" % data)