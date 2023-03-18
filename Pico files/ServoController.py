# ---------- Packages ----------
import machine
import time

# ---------- Variables ----------
# Servo pin number
servoPin = 1

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


    
# Default position
servo_SetPosition(servo_currentPosition_Percentage)

def test():
    d = 0.02
    d2 = 0.5
    for i in range(-100, 100):
        servo_SetPosition(i)
        time.sleep(d)
    time.sleep(d2)
    for i in range(100, -100, -1):
        servo_SetPosition(i)
        time.sleep(d)
    time.sleep(d2)
    
while True:
    test()