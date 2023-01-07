# ---------- Packages ----------
from machine import Pin,PWM
from time import sleep
 

# ---------- Variables ----------
# Servo pin number
motorPin_A_1A = 27
motorPin_A_1B = 26

# Setup pins as PWM
A_1A = PWM(Pin(motorPin_A_1A))
A_1A.freq(1000)
A_1B = PWM(Pin(motorPin_A_1B))
A_1B.freq(1000)
 

# ---------- Functions ----------
# --- Machine functions ---

# Set motor speed in specific direction
def motor_SetSpeed(inputSpeedPercentage, direction):
    print(inputSpeedPercentage, ' in ', direction)

    # Brake if the speed or direction is 0
    if inputSpeedPercentage is 0 or direction is 0:
        A_1A.duty_u16(0)
        A_1B.duty_u16(0)
        return

    # Calculations for the output
    actualMinPercentage = 20
    actualMaxPercentage = 50
    actualSpeedPercentage = inputSpeedPercentage / 100 * (actualMaxPercentage - actualMinPercentage) + actualMinPercentage
    speedValue = round(actualSpeedPercentage * 65535 / 100)
    print(actualSpeedPercentage, ' in ', direction)

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

# Drive / set motor speed
def motor_Forwards(speedPercentage):
    motor_SetSpeed(speedPercentage, 1)

# Drive / set motor speed
def motor_Backwards(speedPercentage):
    motor_SetSpeed(speedPercentage, -1)
    
# Drive / set motor speed
def motor_Brake():
    motor_SetSpeed(0, 0)



# Default stopped
motor_Brake()