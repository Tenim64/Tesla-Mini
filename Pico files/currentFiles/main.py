# -------------------------- Main program --------------------------
# ---------- Packages ----------
import json
from time import sleep
from machine import Pin
import network
import socket
import sys


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
                setPosition(currentPosition_Percentage)

def testProcess():
    setPosition(-100)
    sleep(2)
    setPosition(0)
    sleep(2)
    setPosition(100)
    sleep(2)
    setPosition(0)


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
        setPosition(currentPosition_Percentage)
        while runProgram:
            sleep(5)
            testProcess()
        sys.exit()
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



# -------------------------- Servo controller -------------------------- 
# ---------- Packages ----------
import machine


# ---------- Variables ----------
# Servo pin number
servoPin = 1

# Servo turn values
analogRange = 225       # [ 0 ; 360 ]
digitalRange = 180      # [ 0 ; analogRange ]
analogOffset = 6       # [ 0 ; digitalOffset ]
digitalOffset = 45      # [ 0 ; analogRange - digitalRange ]
marginAngle = 50        # [ 0 ; actualRange / 2]

# Calculated servo turn values
actualStart_Degrees = digitalOffset + 2 * analogOffset + marginAngle
actualEnd_Degrees = digitalRange + digitalOffset - marginAngle
actualRange_Degrees = actualEnd_Degrees - actualStart_Degrees

# Position values
currentPosition_Percentage = 0      # [ -100 ; 100 ]

# ---------- Functions ----------
def t():
    testProcess()
# --- Machine functions ---

# Convert degrees to analog data
def degreesToAnalog(position_Degrees):
    position_Analog = round((position_Degrees * 8000 / 225 + 1000) / 50) * 50
    return position_Analog

# Convert analog data to degrees
def analogToDegrees(position_Analog):
    position_Degrees = round((position_Analog - 1000) / 8000 * 225)
    return position_Degrees

# Convert percentage to degrees
def percentageToDegrees(position_Percentage):
    positionProcessed_Degrees = analogRange - ((position_Percentage / 100 + 1) / 2 * actualRange_Degrees + actualStart_Degrees)
    return positionProcessed_Degrees

# Turn function using percentage as input
def turnPercentage(position_Percentage):
    # Position(%) ∈ [ -100 ; 100 ]
    positionProcessed_Percentage = min(max(position_Percentage, -100), 100)

    # Save new position
    global currentPosition_Percentage
    currentPosition_Percentage = positionProcessed_Percentage

    # Convert position from percentage to degrees
    positionProcessed_Degrees = percentageToDegrees(positionProcessed_Percentage)

    # Convert position from degrees to analog data
    positionProcessed_Analog = degreesToAnalog(positionProcessed_Degrees)
    # Turn
    turnAnalog(positionProcessed_Analog)


    print(positionProcessed_Percentage, "% | ", positionProcessed_Degrees, "° | ", positionProcessed_Analog)

# Turn function using analog data as input
def turnAnalog(position_Analog):
    global servoPin
    servo = machine.PWM(machine.Pin(servoPin))
    servo.freq(50)
    servo.duty_u16(position_Analog)

# --- User functions ---

# Set position
def setPosition(position_Percentage):
    turnPercentage(position_Percentage)

# Full left turn
def full_left():
    turnPercentage(-100)
    
# Full right turn
def full_right():
    turnPercentage(100)

# Turn left n degrees
def turn_left(positionChange_Percentage):
    global currentPosition_Percentage
    currentPosition_Percentage -= positionChange_Percentage
    turnPercentage(currentPosition_Percentage)

# Turn right n degrees
def turn_right(positionChange_Percentage):
    global currentPosition_Percentage
    currentPosition_Percentage += positionChange_Percentage
    turnPercentage(currentPosition_Percentage)



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