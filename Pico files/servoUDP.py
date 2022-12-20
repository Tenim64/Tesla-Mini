# -------------------------- Main program --------------------------
# ---------- Packages ----------
import json
from time import sleep


# ---------- Variables ----------
wlan = None
s = None


# ---------- Functions ----------
def processData(data):
    blink(1)
    print("Data received: " + data)
    data_object = json.loads(data)
    data_title = data_object["title"]
    data_data = data_object["data"]
    if data_title and data_data:
        if (data_title == "state"):
            if (data_data == "Testing"):
                testProcess()

def testProcess():
    setPosition(0)
    sleep(2)
    setPosition(180)
    sleep(2)
    setPosition(90)


# ---------- Program ----------
def main():
    try:
        # Set the default turn position
        setPosition(currentPosition)
        # Setup the network
        setupNetwork()
        # Make a socket
        makeSocket(wlan)
        # Listen to the socket
        listenToSocket(s)
    except Exception as e:
        print(e)



# -------------------------- Servo controller -------------------------- 
# ---------- Packages ----------
import machine


# ---------- Variables ----------
servoPin = 1

angleRange = 225
digitalRange = 180

currentPosition = 90


# ---------- Functions ----------

# --- Machine functions ---

# Convert degrees to analog data
def degreesToAnalog(degrees):
    analog = round((degrees * 8000 / 225 + 1000) / 50) * 50
    return analog

# Convert analog data to degrees
def analogToDegrees(analog):
    degrees = round((analog - 1000) * 225 / 8000)
    return degrees

# Turn function using analog data as input
def turnAnalog(position):
    global servoPin
    servo = machine.PWM(machine.Pin(servoPin))
    servo.freq(50)
    global currentPosition
    currentPosition = degreesToAnalog(min(max(analogToDegrees(position), 0), digitalRange - 1))
    servo.duty_u16(currentPosition)
    print("Turned to ", analogToDegrees(currentPosition), " degrees.")

# --- User functions ---

# Set position
def setPosition(degrees):
    position = degreesToAnalog(180 - degrees)
    turnAnalog(position)

# Full left turn
def full_left():
    setPosition(angleRange - 1)
    
# Full right turn
def full_right():
    setPosition(0)

# Turn left n degrees
def turn_left(degrees):
    servo = machine.PWM(machine.Pin(servoPin))
    servo.freq(50)
    global currentPosition
    currentPosition = degreesToAnalog(analogToDegrees(currentPosition) + degrees)
    turnAnalog(currentPosition)

# Turn right n degrees
def turn_right(degrees):
    servo = machine.PWM(machine.Pin(servoPin))
    servo.freq(50)
    global currentPosition
    currentPosition = degreesToAnalog(analogToDegrees(currentPosition) - degrees)
    turnAnalog(currentPosition)



# -------------------------- UDP receiver --------------------------
# ---------- Packages ----------
import network
import socket
from time import sleep
from machine import Pin

# ---------- Led ----------
print('Preparing software...')

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

# ---------- Connecting ----------
def makeSocket(wlan):
    global s
    # Create a socket
    s = socket.socket()
    # Bind the socket to a local address and port
    s.bind((wlan.ifconfig()[0], 80))
    print("Socket bound")

def listenToSocket(s):
    # Listen for incoming connections
    s.listen(1)
    print("Listening to socket")

    # Accept an incoming connection
    conn, addr = s.accept()
    blink(1)
    print("Connection made")

    # Continuously receive data and print it
    data = None
    while True:
        data = conn.recv(1024).decode()
        if not data:
            continue
        if data != None:
            processData(data)
        data = None



# -------------------------- Run program --------------------------
main()