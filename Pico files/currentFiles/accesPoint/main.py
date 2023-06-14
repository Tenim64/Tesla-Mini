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
# Low battery pin
lowbatteryPin = Pin(19, Pin.IN)
# Charging pin
chargingPin = Pin(21, Pin.IN)


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
        makeSocket()
        while True:
            try:
                # Receive data from the socket
                receiveSocketData()
                closeSocket()
            except Exception as e:
                print(e)
                try:
                    # Listen to the socket
                    listenToSocket()
                except Exception as e2:
                    print(e2)
                    # Remake a socket
                    makeSocket()
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
    
    tries = 0
    
    while True :
        tries += 1
        # Write that this the start of the data packet
        uart.write("\\start\\")
        # Write data to serial
        uart.write(data)
        # Write that this the end of the data packet
        uart.write("\\end\\")
        
        # Stop if response
        if getSerialHandshake():
            break
        # Stop if no response
        if tries >= 5 and (not getSerialHandshake()):
            break
        
    if tries >= 5:
        print("failed to send data, no response")
    else:
        print("serial data successfully sent: ", data)
    
def getSerialHandshake():
    global uart
    
    buffer = ""
    while True:
        try:
            if uart.any():
                buffer += uart.read().decode()
                if "\\end\\" in buffer:
                    if "\\start\\" in buffer:
                        data = buffer.replace("\\start\\","").replace("\\end\\","")
                        if data == "ACK":
                            print("ack gotten")
                            return True
                        else:
                            return False
                    else:
                        print("Corrupted data")
                    buffer = ""
                    return False
        except Exception as e:
            print(e)
            print("Corrupted data")
            buffer = ""
            return False




# -------------------------------- Network --------------------------------
# ---------- Functions ----------
def processGetRequest(data_request):
    global sConn, lowbatteryPin, chargingPin

    response = {}
    response["title"] = data_request

    print("data_request: ", data_request)
    if data_request == "battery":
        lowbattery = not lowbatteryPin.value()
        lowbattery = False
        print(chargingPin.value())
        charging = not chargingPin.value()
        print("lowbattery: ", lowbattery)
        print("charging: ", charging)
        
        if lowbattery:
            response["data"] = "low"
        else:
            response["data"] = "charged"
        if charging:
            response["data"] = "charging"

    if data_request == "connection":
        response["data"] = "active"
        
    print("response: ", json.dumps(response))
    sConn.send(json.dumps(response).encode())    

def processData(data):
    if data == "":
        return
    # Get data from json
    try:
        data_object = json.loads(data)
        data_title = data_object["title"]
    except:
        return
    
    print("Data received!")
    blink(1)
    
    # If no data was found, return
    if data_title == None:
        return
    # Get requests
    if data_title == "get":
        data_data = data_object["data"]
        processGetRequest(data_data)
        return
    if data_title == "connection":
        print("Connection change: acknowledged")
        sConn.send("ack".encode())    
        return
    if data_title == "control":
        data_speed = data_object["speed"]
        data_turnAngle = data_object["turnAngle"]
        # Send to data to RPI Pico
        print(f"speed - {data_speed}")
        sendSerial(f"{data_title}\\-\\drive={data_speed}")
        print(f"turnAngle - {data_turnAngle}")
        sendSerial(f"{data_title}\\-\\turn={data_turnAngle}")
        sConn.send("{\"title\": \"getControls\"}".encode())
        return

    sConn.send("ack".encode())   


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
def makeSocket():
    global s, wlan
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
    print("Socket bound")
    listenToSocket()

def listenToSocket():
    global s, sConn
    # Listen for incoming connections
    s.listen(1)
    print("Listening to socket")

    # Accept an incoming connection
    try:
        sConn, sAddr = s.accept()
    except Exception as e:
        pass
    print("Connection made")    
    blink(1)

def receiveSocketData():
    global s, sConn
    # Continuously receive data and process it
    data = None
    while True:
        for i in range(0,1000):
            # If there is data, process it
            data = sConn.readline()
            processData(data)
        try:
            sConn.send("status check")
            print("status check: success")
        except:
            print("status check: fail")
            break
            
def closeConnection():
    global sConn

    sConn.close() 
    
def closeSocket():
    global s
    
    s.close()
        
# Run
boot()

