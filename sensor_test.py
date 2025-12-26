import board
import busio
from adafruit_mcp9808 import MCP9808

# Initialize I2C bus
i2c = busio.I2C(board.SCL, board.SDA)

# Initialize sensor
sensor = MCP9808(i2c)

# Read and print temperature
print(f"Temperature: {sensor.temperature:.2f} °C")
