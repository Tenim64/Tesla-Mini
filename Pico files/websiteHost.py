# type:ignore
# ---------- Packages ----------
import json
from time import sleep
from machine import Pin
import network
import socket
import select
import gc
gc.collect()
gc.mem_free()


# ---------- Variables ----------
wlan = network.WLAN(network.AP_IF)
s = None
sConn = None


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

        data_title = "control"
        data_data = data.split()[1][1:]
    else:
        data_object = json.loads(data)
        data_title = data_object["title"]
        data_data = data_object["data"]
    
    print(data_title,"-",data_data)
    if data_title and data_data:
        if (data_title == "control"):
            sleep(0.5)
            if (data_data == "forwards"):
                blink(3)
            if (data_data == "backwards"):
                blink(4)
            if (data_data == "left"):
                blink(5)
            if (data_data == "right"):
                blink(6)
            if (data_data == "brake"):
                blink(7)

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
    print("Send webpage")

    # Send the response to the client
    sConn.send(response.encode()) 


# -------------------------------- Main --------------------------------
def main():
    try:
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
                try:
                    # Listen to the socket
                    listenToSocket()
                except Exception as e:
                    # Remake a socket
                    makeSocket(wlan)
    except Exception as e:
        print(e)

main()