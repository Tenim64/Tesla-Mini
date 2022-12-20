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

# ---------- Functions ----------
def checkConnections():
  print(wlan.ifconfig())

# ---------- Setup network ----------
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
# Create a socket
s = socket.socket()
# Bind the socket to a local address and port
s.bind((wlan.ifconfig()[0], 80))
print("Socket bound")

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
    print("Data received: " + data)
    blink(1)
  data = None