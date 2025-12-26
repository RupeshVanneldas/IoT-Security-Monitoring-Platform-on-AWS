import time
import json
import logging

# Hardware libraries for Raspberry Pi I2C communication
import board
import busio
from adafruit_mcp9808 import MCP9808

# AWS IoT SDK (installed inside virtual environment)
from AWSIoTPythonSDK.MQTTLib import AWSIoTMQTTClient


# Configure logging for visibility in terminal output
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("AWSIoT")


# Initialize I2C bus and MCP9808 temperature sensor
i2c = busio.I2C(board.SCL, board.SDA)
sensor = MCP9808(i2c)


# AWS IoT Core endpoint (replace with your actual endpoint)
AWS_ENDPOINT = "YOUR_ENDPOINT_HERE-ats.iot.us-east-1.amazonaws.com"

# Root CA used to verify AWS IoT server
ROOT_CA = "/home/iotuser/certs/root-CA.crt"

# Device certificate that identifies this Raspberry Pi
CERT = "/home/iotuser/certs/raspberrypi-temp-sensor.cert.pem"

# Private key corresponding to the device certificate
KEY = "/home/iotuser/certs/raspberrypi-temp-sensor.private.key"

# MQTT topic to publish temperature data
TOPIC = "raspberrypi/temperature"

# MQTT client ID (must match IoT policy)
CLIENT_ID = "raspberrypi-temp-sensor"


# Configure MQTT client for AWS IoT Core
client = AWSIoTMQTTClient(CLIENT_ID)
client.configureEndpoint(AWS_ENDPOINT, 8883)
client.configureCredentials(ROOT_CA, KEY, CERT)

# Auto-reconnect and timeout settings for stability
client.configureAutoReconnectBackoffTime(1, 32, 20)
client.configureConnectDisconnectTimeout(10)
client.configureMQTTOperationTimeout(5)


# Connect securely to AWS IoT Core
client.connect()
logger.info("Connected to AWS IoT Core successfully")


# Continuously read temperature and publish to AWS IoT Core
while True:
    try:
        # Read temperature from MCP9808 in Celsius
        temperature = sensor.temperature

        # Create JSON payload
        payload = {
            "temperature": round(temperature, 2),
            "unit": "C",
            "device": "raspberrypi-temp-sensor",
            "timestamp": time.time()
        }

        # Publish message to MQTT topic
        client.publish(TOPIC, json.dumps(payload), 1)
        logger.info(payload)

        # Publish every 5 seconds
        time.sleep(5)

    except Exception as e:
        logger.error(e)
        time.sleep(5)
