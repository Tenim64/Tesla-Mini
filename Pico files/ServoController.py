# ---------- Packages ----------
import machine


# ---------- Variables ----------
# Servo pin number
servoPin = 1

# Servo turn values
analogRange = 225       # [ 0 ; 360 ]
digitalRange = 180      # [ 0 ; analogRange ]
analogOffset = 4       # [ 0 ; digitalOffset ]
digitalOffset = 45      # [ 0 ; analogRange - digitalRange ]
marginAngle = 50        # [ 0 ; actualRange / 2]

# Calculated servo turn values
actualStart_Degrees = digitalOffset + 2 * analogOffset + marginAngle
actualEnd_Degrees = digitalRange + digitalOffset - marginAngle
actualRange_Degrees = actualEnd_Degrees - actualStart_Degrees

# Position values
currentPosition_Percentage = 0      # [ -100 ; 100 ]

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
    positionProcessed_Degrees = analogRange - ((position_Percentage / 100 + 1) / 2 * actualRange_Degrees + actualStart_Degrees)
    return positionProcessed_Degrees

# Turn function using percentage as input
def servo_TurnPercentage(position_Percentage):
    # Position(%) ∈ [ -100 ; 100 ]
    positionProcessed_Percentage = min(max(position_Percentage, -100), 100)

    # Save new position
    global currentPosition_Percentage
    currentPosition_Percentage = positionProcessed_Percentage

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
    global currentPosition_Percentage
    currentPosition_Percentage -= positionChange_Percentage
    servo_TurnPercentage(currentPosition_Percentage)

# Turn right n degrees
def servo_TurnRight(positionChange_Percentage):
    global currentPosition_Percentage
    currentPosition_Percentage += positionChange_Percentage
    servo_TurnPercentage(currentPosition_Percentage)


    
# Default position
servo_SetPosition(currentPosition_Percentage)