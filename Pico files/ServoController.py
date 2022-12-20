# ---------- Packages ----------
import machine


# ---------- Variables ----------
led= machine.Pin(25, machine.Pin.OUT)
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
    print(currentPosition)
    print(analogToDegrees(currentPosition))

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
    
    
# Default position
setPosition(currentPosition)