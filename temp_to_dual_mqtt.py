import time
import json
import logging

# Hardware libraries for Raspberry Pi I2C communication
import board
import busio
from adafruit_mcp9808 import MCP9808

# AWS IoT SDK
from AWSIoTPythonSDK.MQTTLib import AWSIoTMQTTClient

# Local MQTT client for EC2 Mosquitto
import paho.mqtt.client as mqtt


# Configure logging for visibility
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("AWSIoT")


# Initialize I2C bus and MCP9808 temperature sensor
i2c = busio.I2C(board.SCL, board.SDA)
sensor = MCP9808(i2c)


# AWS IoT Core endpoint
AWS_ENDPOINT = "<IOT_ENDPOINT>-ats.iot.us-east-1.amazonaws.com"

# Certificate paths
ROOT_CA = "/home/iotuser/certs/root-CA.crt"
CERT = "/home/iotuser/certs/raspberrypi-temp-sensor.cert.pem"
KEY = "/home/iotuser/certs/raspberrypi-temp-sensor.private.key"

# AWS IoT MQTT configuration
TOPIC = "raspberrypi/temperature"
CLIENT_ID = "raspberrypi-temp-sensor"


# EC2 Mosquitto configuration
EC2_MQTT_BROKER = "<EC2_INSTANCE_PUBLIC_IP>"
EC2_MQTT_PORT = 1883
EC2_MQTT_TOPIC = "raspberrypi/temperature"


# Configure AWS IoT MQTT client
client = AWSIoTMQTTClient(CLIENT_ID)
client.configureEndpoint(AWS_ENDPOINT, 8883)
client.configureCredentials(ROOT_CA, KEY, CERT)

client.configureAutoReconnectBackoffTime(1, 32, 20)
client.configureConnectDisconnectTimeout(10)
client.configureMQTTOperationTimeout(5)

client.connect()
logger.info("Connected to AWS IoT Core successfully")


# Configure EC2 Mosquitto MQTT client
ec2_client = mqtt.Client(client_id="raspberrypi-ec2-mirror")
ec2_client.connect(EC2_MQTT_BROKER, EC2_MQTT_PORT, 60)
ec2_client.loop_start()

logger.info("Connected to EC2 Mosquitto broker successfully")


# Continuously read temperature and publish to both destinations
while True:
    try:
        temperature = sensor.temperature

        payload = {
            "temperature": round(temperature, 2),
            "unit": "C",
            "device": "raspberrypi-temp-sensor",
            "timestamp": time.time()
        }

        payload_json = json.dumps(payload)

        # Publish to AWS IoT Core (TLS)
        client.publish(TOPIC, payload_json, 1)

        # Publish to EC2 Mosquitto (plaintext for IDS inspection)
        ec2_client.publish(EC2_MQTT_TOPIC, payload_json)

        logger.info(payload)

        time.sleep(5) # Delay between readings

    except Exception as e:
        logger.error(e)
        time.sleep(5)
