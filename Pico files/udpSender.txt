import microap
import socket
import machine

# Set the name and password of the WiFi AP
ssid = "MyAP"
password = "password"

# Set the port for the UDP socket
port = 10000

# Create the WiFi AP
microap.start(ssid=ssid, password=password)

# Wait for a connection to be made
print("Waiting for a connection...")
while not microap.is_connected():
    pass

# Print the IP address of the connected device
print(f"Connected device: {microap.client_ip()}")

# Create a UDP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Set up the button
button = machine.Pin(0, machine.Pin.IN, machine.Pin.PULL_UP)

# Run indefinitely
while True:
    # Check if the button is pressed
    if not button.value():
        # Send a UDP packet to all connected devices
        message = b"Button pressed!"
        sock.sendto(message, ("255.255.255.255", port))
        print(f"Sent {message} to all connected devices")

# Stop the WiFi AP
microap.stop()
