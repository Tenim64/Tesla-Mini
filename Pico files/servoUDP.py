# -------------------------- Main program --------------------------
# ---------- Packages ----------
import json
from time import sleep
from machine import Pin
import network
import socket


# ---------- Variables ----------
wlan = network.WLAN(network.AP_IF)
s = None
sConn = None

powerBtnPin = 2
powerBtn = Pin(powerBtnPin, Pin.IN, Pin.PULL_UP)


# ---------- Functions ----------
def runProgram():
    return (powerBtn.value() == 1)

def processData(data):
    blink(1)
    print("Data received: " + data)
    data_object = json.loads(data)
    data_title = data_object["title"]
    data_data = data_object["data"]
    if data_title and data_data:
        if (data_title == "state"):
            print(data_data)
            if (data_data == "Testing"):
                testProcess()
            if (data_data == "Starting" or data_data == "Stopping"):
                servo_SetPosition(servo_currentPosition_Percentage)

def testProcess():
    servo_SetPosition(-100)
    sleep(2)
    servo_SetPosition(0)
    sleep(2)
    servo_SetPosition(100)
    sleep(2)
    servo_SetPosition(0)


# ---------- Program ----------
def boot():
    print('Software ready!')
    while True:
        blink(1)
        sleep(1)
        while not runProgram:
            pass
        print("Powered on!")
        main()
        while runProgram:
            pass
        print("Powered off!")

def main():
    try:
        # Set the default turn position
        servo_SetPosition(servo_currentPosition_Percentage)
        # Stop possible previous network
        stopNetwork()
        # Setup the network
        setupNetwork()
        # Make a socket
        makeSocket(wlan)
        while runProgram:
            try:
                # Listen to the socket
                receiveSocketData(s)
            except Exception as e:
                print(e)
                # Remake a socket
                makeSocket(wlan)
    except Exception as e:
        print(e)



# ---------- Packages ----------
import machine


# ---------- Variables ----------
# Servo pin number
servoPin = 25

# Servo turn values
servo_analogRange = 225       # [ 0 ; 360 ]
servo_digitalRange = 180      # [ 0 ; servo_analogRange ]
servo_analogOffset = 4       # [ 0 ; servo_digitalOffset ]
servo_digitalOffset = 45      # [ 0 ; servo_analogRange - servo_digitalRange ]
servo_marginAngle = 50        # [ 0 ; actualRange / 2]

# Calculated servo turn values
servo_actualStart_Degrees = servo_digitalOffset + 2 * servo_analogOffset + servo_marginAngle
servo_actualEnd_Degrees = servo_digitalRange + servo_digitalOffset - servo_marginAngle
servo_actualRange_Degrees = servo_actualEnd_Degrees - servo_actualStart_Degrees

# Position values
servo_currentPosition_Percentage = 0      # [ -100 ; 100 ]

# ---------- Functions ----------
# --- Machine functions ---

# Convert degrees to analog data
def servo_DegreesToAnalog(position_Degrees):
    position_Analog = round((position_Degrees * 8000 / 225 + 1000) / 50) * 50
    return position_Analog

# Convert analog data to degrees
def servo_AnalogToDegrees(position_Analog):
    position_Degrees = round((position_Analog - 1000) / 8000 * 225)
    return position_Degrees

# Convert percentage to degrees
def servo_PercentageToDegrees(position_Percentage):
    positionProcessed_Degrees = servo_analogRange - ((position_Percentage / 100 + 1) / 2 * servo_actualRange_Degrees + servo_actualStart_Degrees)
    return positionProcessed_Degrees

# Turn function using percentage as input
def servo_TurnPercentage(position_Percentage):
    # Position(%) ∈ [ -100 ; 100 ]
    positionProcessed_Percentage = min(max(position_Percentage, -100), 100)

    # Save new position
    global servo_currentPosition_Percentage
    servo_currentPosition_Percentage = positionProcessed_Percentage

    # Convert position from percentage to degrees
    positionProcessed_Degrees = servo_PercentageToDegrees(positionProcessed_Percentage)

    # Convert position from degrees to analog data
    positionProcessed_Analog = servo_DegreesToAnalog(positionProcessed_Degrees)
    # Turn
    servo_TurnAnalog(positionProcessed_Analog)

    print(positionProcessed_Percentage, "% | ", positionProcessed_Degrees, "° | ", positionProcessed_Analog)

# Turn function using analog data as input
def servo_TurnAnalog(position_Analog):
    global servoPin
    servo = machine.PWM(machine.Pin(servoPin))
    servo.freq(50)
    servo.duty_u16(position_Analog)

# --- User functions ---

# Set position
def servo_SetPosition(position_Percentage):
    servo_TurnPercentage(position_Percentage)

# Full left turn
def servo_FullLeft():
    servo_TurnPercentage(-100)
    
# Full right turn
def servo_FullRight():
    servo_TurnPercentage(100)

# Turn left n degrees
def servo_TurnLeft(positionChange_Percentage):
    global servo_currentPosition_Percentage
    servo_currentPosition_Percentage -= positionChange_Percentage
    servo_TurnPercentage(servo_currentPosition_Percentage)

# Turn right n degrees
def servo_TurnRight(positionChange_Percentage):
    global servo_currentPosition_Percentage
    servo_currentPosition_Percentage += positionChange_Percentage
    servo_TurnPercentage(servo_currentPosition_Percentage)



# -------------------------- UDP receiver --------------------------
# ---------- Packages ----------
import network
import socket
from time import sleep
from machine import Pin
import select

# ---------- Led ----------
led = Pin("LED", Pin.OUT)
led.off()
def blink(blinks):
  for i in range(0, blinks):
    led.toggle()
    sleep(0.1)
    led.toggle()
    sleep(0.2)
  sleep(0.3)

# ---------- Setup network ----------
def setupNetwork():
    global wlan
    print('Setting up network...')
    # Set network type
    wlan = network.WLAN(network.AP_IF)
    # Set the name and password of the WiFi AP
    ssid = "Tesla Mini"
    password = ".'.'.'.'"
    # Create the WiFi AP
    # ip, subnet, gateway, dns
    wlan.ifconfig(('192.168.4.1', '255.255.255.0', '192.168.4.1', '8.8.8.8'))
    wlan.config(essid=ssid, password=password)
    # Start network
    print('Starting network...')
    wlan.active(True)
    # Wait to start
    while wlan.active() == False:
        wlan.active(True)
        pass
    print("Acces point active on IP: " + wlan.ifconfig()[0])
    print("Connect to \"" + ssid + "\" using the password \"" + password + "\"")
    blink(2)

# ---- Stop network ----
def stopNetwork():
    global wlan
    wlan.active(False)
    print('Stopped network')

# ---------- Connecting ----------
def makeSocket(wlan):
    global s
    # Remove possible previous socket
    try:
        s.close() # type:ignore
    except Exception as e:
        pass
    # Create a socket
    s = socket.socket()
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    # Bind the socket to a local address and port
    s.bind((wlan.ifconfig()[0], 80))
    s.setblocking(0)
    print("Socket bound")
    listenToSocket(s)

def listenToSocket(s):
    global sConn
    # Listen for incoming connections
    s.listen()
    print("Listening to socket")

    # Accept an incoming connection
    while runProgram:
        try:
            sConn, sAddr = s.accept()
            break
        except Exception as e:
            pass
    if not runProgram:
        return
    blink(1)
    print("Connection made")

def receiveSocketData(s):
    global sConn
    # Continuously receive data and process it
    data = None
    while runProgram:
        # Check if connection is still active
        connected = select.select([s], [], [], 0)
        if not connected:
            print("Connection lost")
            raise Exception("Connection lost")
        # If there is data, process it
        data = sConn.recv(1024).decode() # type:ignore
        if not data:
            continue
        if data != None:
            processData(data)
        data = None



# -------------------------- Run program --------------------------
boot()