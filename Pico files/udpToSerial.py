# -------------------------------- Pre-script --------------------------------
# type:ignore
# -> this causes IDEs to not complain about what type a variable is
# -> who doesn't like simply ignoring errors when you can


# ---------- Packages ----------
import gc
import machine
from machine import Pin
import json
from time import sleep
import network
import socket
import select


# ---------- Clean memory ----------
# Increase run time and decrease chance of code failure
# Collect possible garbage/cache
gc.collect()
# Free memory if possible
gc.mem_free()


# ---------- Variables ----------
wlan = network.WLAN(network.AP_IF)
s = None
sConn = None
uart = None
led = Pin("LED", Pin.OUT)
production = False


# ---------- Debug tools ----------
print('Preparing software...')

# LED controller
# Set default LED state
led.off()
# Function to blink n times
def blink(blinks):
    if not production:
        return
    # Simple blink script
    for i in range(0, blinks):
        led.toggle()
        sleep(0.1)
        led.toggle()
        sleep(0.2)
    # Extra sleep in case of another blink function call
    sleep(0.3)



# -------------------------------- Program --------------------------------
def boot():
    main()
def main():
    try:
        # Start serial
        setupSerial()
        # Stop possible previous network
        stopNetwork()
        # Setup the network
        setupNetwork()
        # Make a socket
        makeSocket(wlan)
        while True:
            try:
                # Receive data from the socket
                receiveSocketData()
                # Receive data from the socket
                closeSocket()
            except Exception as e:
                print(e)
                try:
                    # Listen to the socket
                    listenToSocket()
                except Exception as e2:
                    print(e2)
                    # Remake a socket
                    makeSocket(wlan)
    except Exception as e:
        print(e)



# -------------------------------- Serial --------------------------------
# ---------- Functions ----------
def setupSerial():
    global uart
    # Setup serial
    uart = machine.UART(0, baudrate=9600)
    uart.init(baudrate=9600, bits=8, parity=None, stop=1)

def sendSerial(data):
    global uart
    # Write that this the start of the data packet
    uart.write("\\start\\")
    # Write data to serial
    uart.write(data)
    # Write that this the end of the data packet
    uart.write("\\end\\")

    print("serial data sent: ", data)



# -------------------------------- Network --------------------------------
# ---------- Functions ----------
def processData(data):
    blink(1)
    print("Data received!")

    global sConn

    # Get data from json
    data_object = json.loads(data)
    data_title = data_object["title"]
    data_data = data_object["data"]
    
    # If no data was found, return
    if data_title != None:
        # Send to data to RPI Pico
        print(f"{data_title} - {data_data}")
        sendSerial(f"{data_title}\\-\\{data_data}")

    # Close connection
    sConn.close() 


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
        s.close()
    except Exception as e:
        pass
    # Create a socket
    s = socket.socket()
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    # Bind the socket to a local address and port
    s.bind((wlan.ifconfig()[0], 80))
    s.setblocking(1)
    print("Socket bound")
    listenToSocket()

def listenToSocket():
    global s, sConn
    # Listen for incoming connections
    s.listen()
    print("Listening to socket")

    # Accept an incoming connection
    while True:
        try:
            sConn, sAddr = s.accept()
            break
        except Exception as e:
            pass
    print("Connection made")    
    blink(1)

def receiveSocketData():
    global s, sConn
    # Continuously receive data and process it
    data = None
    while True:
        # If there is data, process it
        data = sConn.recv(1024).decode()
        if not data:
            continue
        if data != None:
            processData(data)

        data = None
        
def closeSocket():
    global s
    
    s.close()
        
# Run
boot()