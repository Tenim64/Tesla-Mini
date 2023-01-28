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


# ---------- Debug tools ----------
print('Preparing software...')

# LED controller
# Set default LED state
led.off()
# Function to blink n times
def blink(blinks):
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

    # Check data is coming from a webbrowser or the app
    # Then process it based on the source
    if data.split()[0] == "GET":
        print("GET")

        url = data.split()[1]
        sendWebpage(url)

        data_title = getQueryValue(url, "title")
        data_data = getQueryValue(url, "data")
    else:
        data_object = json.loads(data)
        data_title = data_object["title"]
        data_data = data_object["data"]
    
    if data_title == None:
        return

    print(f"{data_title} - {data_data}")
    sendSerial(f"{data_title}\\-\\{data_data}")

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
        sleep(0.1)
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
    s.setblocking(0)
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
    blink(1)
    print("Connection made")

def receiveSocketData():
    global s, sConn
    # Continuously receive data and process it
    data = None
    while True:
        # Check if connection is still active
        connected = select.select([s], [], [], 0)
        if not connected:
            print("Connection lost")
            raise Exception("Connection lost")
        # If there is data, process it
        data = sConn.recv(1024).decode() 
        if not data:
            continue
        if data != None:
            processData(data)

        data = None

# ---------- Send webpage ----------
def sendWebpage(page):
    global sConn
    # If the request URL is not '/', return a 404 Not Found response
    if page != '/':
        response = 'HTTP/1.1 404 Not Found\n'
        response += 'Content-Type: text/html\n'
        response += '\n'
        response += '<html><body>404 Not Found</body></html>\n'
        sConn.send(response.encode()) 
        return

    # Page
    webpageFile = open("./index.html", "r")
    html = webpageFile.read()
    html_compact = html.replace('\n', ' ').replace('\r', '')
    webpageFile.close()

    # Construct the response
    response = 'HTTP/1.1 200 OK\n'
    response += 'Content-Type: text/html\n'
    response += '\n'
    response += html_compact + '\n'

    # Send the response to the client
    sConn.send(response.encode()) 
    print("Sent webpage")

def getQueryValue(inputUrl, inputKey):
    # Split on first appearance of "?" to get the query
    path, _, queryString = inputUrl.partition('?')
    # Safety check, if "?" was found
    if queryString:
        # Split queries per key
        queryParameters = queryString.split("&")
        # Loop over all the queries
        for parameter in queryParameters:
            # Split the key and value
            key, _, value = parameter.partition("=")
            # Check if the key matches the input
            if key == inputKey:
                # Return value
                return value
    # If key wasn't found, send None
    return None





# Run
boot()