# 📡 IoT Security Monitoring & Attack Analysis Platform

![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)
![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazonaws)
![Suricata](https://img.shields.io/badge/IDS-Suricata-red)
![Elastic](https://img.shields.io/badge/Stack-Elastic-005571?logo=elastic)
![MQTT](https://img.shields.io/badge/Protocol-MQTT-660066)
![License](https://img.shields.io/badge/License-MIT-green)

An **end-to-end IoT Security Monitoring and Attack Analysis Platform** that combines **application-layer intrusion detection** with **cloud-native network traffic analysis**.  
The project focuses on securing MQTT-based IoT communications and correlating IDS alerts with AWS VPC Flow Logs for deeper attack visibility.

---

## 🎯 Project Goals

- Simulate IoT sensor data over MQTT
- Detect malicious and anomalous MQTT traffic
- Centralize security and application logs
- Analyze network-level behavior using AWS VPC Flow Logs
- Correlate IDS alerts with cloud network telemetry

---

## 🏗️ Architecture Overview

---

## 🧰 Technology Stack

### ☁️ Cloud & Infrastructure
- AWS EC2
- AWS VPC
- AWS S3
- AWS VPC Flow Logs
- Amazon Athena
- Terraform

### 🔐 Security & Monitoring
- Suricata IDS (v7.x)
- Custom MQTT detection rules
- Elasticsearch
- Kibana
- Filebeat

### ⚙️ Automation & Configuration
- Ansible
- Ubuntu 22.04 LTS

### 📡 IoT & Messaging
- Mosquitto MQTT Broker
- MQTT Protocol (TCP/1883)

### 🧪 Simulation & Development
- Python
- Bash / CLI tools

---

## 📁 Repository Structure

.
├── README.md
├── LICENSE
├── main.tf
├── athena_queries.sql
├── playbook.yml
├── hosts.ini
├── iot_policy.json
├── sensor_test.py
├── temp_to_aws.py
├── temp_to_dual_mqtt.py
├── files/
│ ├── custom.rules
│ ├── suricata.yaml
│ ├── filebeat.yml
│ ├── mosquitto.conf
│ ├── elasticsearch.yml
│ └── kibana.yml
└── .gitignore


---

## 🚀 Deployment Workflow

### 🔹 Step 1: Infrastructure Provisioning (Terraform)

Terraform provisions:
- Custom VPC and subnet
- Internet Gateway and routing
- EC2 instance with Elastic IP
- Security groups (SSH, MQTT, Elasticsearch, Kibana)
- S3 bucket for VPC Flow Logs
- VPC Flow Logs (ALL traffic)
- Athena database and workgroup

```bash
terraform init
terraform apply

### 🔹 Step 2: Service Setup & Configuration (Ansible)

- Ansible installs and configures:

- Mosquitto (MQTT broker)

- Suricata IDS (OISF Suricata 7.x)

- Elasticsearch

- Kibana

- Filebeat

```bash
ansible-playbook -i hosts.ini playbook.yml --become

### 🔹 Step 3: Elastic Stack Security Configuration

The following steps are intentionally done manually for security reasons (optional for test):

- Reset Elasticsearch elastic user password

- Generate Kibana service account token

- Configure kibana.yml with the token

This avoids storing sensitive credentials in code or automation scripts.

---

## IoT Attack Detection (Suricata + ELK)

🛡️Suricata inspects MQTT traffic on port 1883 using custom rules to detect:

- ✅ Normal sensor data

- 🚨 High-frequency publish attempts

- 🧩 Malformed JSON payloads

- 📦 Oversized MQTT messages

Detected alerts are written to eve.json and forwarded by Filebeat to Elasticsearch for visualization in Kibana.

---

## ☁️ Cloud Network Traffic Analysis (VPC Flow Logs + Athena)

- AWS VPC Flow Logs capture all network traffic

- Logs are stored in Amazon S3

- Athena is used to query flow logs using SQL

- Queries analyze:

    a) MQTT traffic patterns

    b) High-volume sources

    c) Port usage trends

    d) Suspicious traffic bursts

All SQL queries used are documented in: athena_queries.sql

---

##🧪 Attack Scenarios Simulated

Normal IoT temperature updates

MQTT message flooding

Malformed payload injection

Large payload transmission

Each attack produces:

Application-layer IDS alerts (Suricata)

Corresponding network flow records (AWS Flow Logs)

---

##📊 Key Observations

MQTT requires protocol-aware inspection

IDS alerts provide payload-level visibility

VPC Flow Logs provide traffic context, not content

Combining both layers improves detection confidence

---

##📌 Conclusion

This project demonstrates a layered IoT security monitoring approach, integrating host-based intrusion detection with cloud-native network analysis. By combining Suricata, the Elastic Stack, and AWS VPC Flow Logs, the platform enables effective detection, investigation, and correlation of IoT-based attacks.