# ---------- Packages ----------
from machine import Pin,PWM
from time import sleep
 

# ---------- Variables ----------
# Current values
currentSpeed = 0
currentDirection = 0
currentFrequency = 10000

# Servo pin number
motorPin_A_1A = 27
motorPin_A_1B = 26

# Setup pins as PWM
A_1A = PWM(Pin(motorPin_A_1A))
A_1A.freq(currentFrequency)
A_1B = PWM(Pin(motorPin_A_1B))
A_1B.freq(currentFrequency)
 

# ---------- Functions ----------
# --- Machine functions ---

# Set motor speed in specific direction
def motor_SetSpeed(inputSpeedPercentage, direction):
    # Set current values
    global currentSpeed, currentDirection, currentFrequency
    currentSpeed = inputSpeedPercentage
    currentDirection = direction

    # Print current values
    print(inputSpeedPercentage, 'in', direction)
    print('using a frequency of', currentFrequency)

    # Brake if the speed or direction is 0
    if inputSpeedPercentage is 0 or direction is 0:
        A_1A.duty_u16(0)
        A_1B.duty_u16(0)
        return

    # Calculations for the output
    # freq = 100
    actualMinPercentage = 20
    actualMaxPercentage = 100
    # freq = 1000
    actualMinPercentage = 40
    actualMaxPercentage = 100
    # freq = 10000
    actualMinPercentage = 30
    actualMaxPercentage = 100
    actualSpeedPercentage = inputSpeedPercentage / 100 * (actualMaxPercentage - actualMinPercentage) + actualMinPercentage
    speedValue = round(actualSpeedPercentage * 65535 / 100)
    #print(actualSpeedPercentage, ' in ', direction)

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
def f(speedPercentage):
    motor_Forwards(speedPercentage)

# Drive backwards at given speed
def motor_Backwards(speedPercentage):
    motor_SetSpeed(speedPercentage, -1)
def b(speedPercentage):
    motor_Backwards(speedPercentage)
    
# Stop motor
def motor_Brake():
    motor_SetSpeed(0, 0)
def br():
    motor_Brake()
    
# Change frequency
def cf(freq):
    global currentSpeed, currentDirection, currentFrequency
    currentFrequency = freq
    A_1A.freq(currentFrequency)
    A_1B.freq(currentFrequency)
    motor_SetSpeed(currentSpeed, currentDirection)


# Default stopped
motor_Brake()