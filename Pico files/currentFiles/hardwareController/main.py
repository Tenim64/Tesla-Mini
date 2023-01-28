# -------------------------------- Pre-script --------------------------------
# type:ignore
# -> this causes IDEs to not complain about what type a variable is
# -> who doesn't like simply ignoring errors when you can


# ---------- Packages ----------
import gc
import machine
from machine import Pin, PWM
from time import sleep


# ---------- Clean memory ----------
# Increase run time and decrease chance of code failure
# Collect possible garbage/cache
gc.collect()
# Free memory if possible
gc.mem_free()


# ---------- Variables ----------
uart = None
led = Pin("LED", Pin.OUT)
# Servo pin number
servoPin = 25
# Motor pin number
motorPin_A_1A = 27
motorPin_A_1B = 26

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
def processData(data):
    data_title, _, data_data = data.partition("\\-\\")
    print(f"{data_title} - {data_data}")

    if data_title and data_data:

        if (data_title == "state"):
            if (data_data == "Testing"):
                testProcess()
            if (data_data == "Starting" or data_data == "Stopping"):
                servo_SetPosition(servo_currentPosition_Percentage)

        if (data_title == "control"):
            if (data_data == "forwards"):
                global motorCurrentSpeed, motorCurrentDirection
                motorCurrentDirection = 1
                motor_Forwards(motorCurrentSpeed + 10)
            if (data_data == "backwards"):
                global motorCurrentSpeed, motorCurrentDirection
                motorCurrentDirection = -1
                motor_Backwards(motorCurrentSpeed - 10)
            if (data_data == "left"):
                servo_TurnLeft(10)
            if (data_data == "right"):
                servo_TurnRight(10)
            if (data_data == "brake"):
                motor_Brake()


def boot():
    print('Software ready!')
    while True:
        blink(1)
        sleep(1)
        main()

def main():
    while True:
        try:
            if uart.any():
                buffer += uart.read().decode()
                if "\\end\\" in buffer:
                    if "\\start\\" in buffer:
                        data = buffer.replace("\\start\\","").replace("\\end\\","")
                        processData(data)
                        print("Serial data: ", data)
                    else:
                        print("Corrupted data")
                    buffer = ""
        except Exception as e:
            print(e)


# -------------------------------- Serial --------------------------------
# ---------- Functions ----------
def setupSerial():
    uart = machine.UART(0, baudrate=9600)

def sendSerial(data):
    uart.init(baudrate=9600, bits=8, parity=None, stop=1)



# -------------------------- Servo controller -------------------------- 
# ---------- Variables ----------
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



# -------------------------- Motor controller -------------------------- 
# ---------- Variables ----------
# Current values
motorCurrentSpeed = 0
motorCurrentDirection = 0
motorDefaultFrequency = 100

# Setup pins as PWM
A_1A = PWM(Pin(motorPin_A_1A))
A_1A.freq(motorDefaultFrequency)
A_1B = PWM(Pin(motorPin_A_1B))
A_1B.freq(motorDefaultFrequency)
 

# ---------- Functions ----------
# --- Machine functions ---

# Set motor speed in specific direction
def motor_SetSpeed(inputSpeedPercentage, direction):
    # Set current values
    global motorCurrentSpeed, motorCurrentDirection
    motorCurrentSpeed = max(0, min(100, inputSpeedPercentage))
    motorCurrentDirection = max(-1, min(1, round(motorCurrentDirection)))

    # Print current values
    print(inputSpeedPercentage, 'in', direction)

    # Brake if the speed or direction is 0
    if inputSpeedPercentage is 0 or direction is 0:
        A_1A.duty_u16(0)
        A_1B.duty_u16(0)
        return

    # Calculations for the output
    actualMinPercentage = 20
    actualMaxPercentage = 100
    actualSpeedPercentage = inputSpeedPercentage / 100 * (actualMaxPercentage - actualMinPercentage) + actualMinPercentage
    speedValue = round(actualSpeedPercentage * 65535 / 100)

    # Output based on the direction
    if direction > 0:               # If the direction is positive -> move forwards
        A_1A.duty_u16(speedValue)
        A_1B.duty_u16(0)
    elif direction < 0:             # If the direction is negative -> move backwards
        A_1A.duty_u16(0)
        A_1B.duty_u16(speedValue)

# --- User functions ---

# Drive / set motor speed
def motor_Drive(speedPercentage, direction):
    motor_SetSpeed(speedPercentage, direction)

# Drive forwards at given speed
def motor_Forwards(speedPercentage):
    motor_SetSpeed(speedPercentage, 1)

# Drive backwards at given speed
def motor_Backwards(speedPercentage):
    motor_SetSpeed(speedPercentage, -1)
    
# Stop motor
def motor_Brake():
    motor_SetSpeed(0, 0)





# Run
boot()