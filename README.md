# 📡 IoT Security Monitoring & Attack Analysis Platform

![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)
![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazonaws)
![Suricata](https://img.shields.io/badge/IDS-Suricata-red)
![Elastic](https://img.shields.io/badge/Stack-Elastic-005571?logo=elastic)
![MQTT](https://img.shields.io/badge/Protocol-MQTT-660066)
![License](https://img.shields.io/badge/License-MIT-green)

An **end-to-end IoT Security Monitoring and Attack Analysis Platform** that combines **application-layer intrusion detection** with **cloud-native network traffic analysis**.  

The project focuses on securing MQTT-based IoT communications and correlating IDS alerts with AWS VPC Flow Logs for deeper attack visibility.

📄 Detailed documentation with screenshots:
https://bright-blender-e21.notion.site/IoT-Security-Monitoring-and-Attack-Analysis-Platform-2dfe54c3a2c9802bb47de5830a82422e

---

## 🎯 Project Goals

- Simulate IoT sensor data over MQTT
- Detect malicious and anomalous MQTT traffic
- Centralize security and application logs
- Analyze network-level behavior using AWS VPC Flow Logs
- Correlate IDS alerts with cloud network telemetry

---

## 🏗️ Architecture Overview

<img width="1536" height="1024" alt="ChatGPT Image Dec 26, 2025, 01_37_09 AM" src="https://github.com/user-attachments/assets/c251550c-03b8-404a-aff8-e0b038c99c09" />

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

## ⚡ High-Level Execution Flow

1. Provision cloud infrastructure using Terraform
2. Configure and deploy services using Ansible
3. Simulate IoT MQTT traffic and attack scenarios
4. Detect malicious payloads using Suricata IDS
5. Visualize alerts in Kibana
6. Analyze network traffic using Athena and VPC Flow Logs
7. Correlate application-layer alerts with network behavior

---

## 🤖 Automation vs Manual Configuration

| Component | Method |
|----------|-------|
| AWS Infrastructure | Terraform |
| Service Installation & Config | Ansible |
| Suricata Rules | Version-controlled |
| Log Shipping | Automated (Filebeat) |
| Elastic Password & Tokens | Manual (Security Best Practice) |
| Athena Table Creation | Manual (SQL) |

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
```

### 🔹 Step 2: Service Setup & Configuration (Ansible)

- Ansible installs and configures:

- Mosquitto (MQTT broker)

- Suricata IDS (OISF Suricata 7.x)

- Elasticsearch

- Kibana

- Filebeat

```bash
ansible-playbook -i hosts.ini playbook.yml --become
```

### 🔹 Step 3: Elastic Stack Security Configuration

The following steps are intentionally done manually for security reasons (optional for test):

- Reset Elasticsearch elastic user password

- Generate Kibana service account token

- Configure kibana.yml with the token

This avoids storing sensitive credentials in code or automation scripts.

---

## 🛡️ IoT Attack Detection (Suricata + ELK)

Suricata inspects MQTT traffic on port 1883 using custom rules to detect:

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

## 🧪 Attack Scenarios Simulated

- Normal IoT temperature updates

- MQTT message flooding

- Malformed payload injection

- Large payload transmission

- Each attack produces:

    i) Application-layer IDS alerts (Suricata)

    ii) Corresponding network flow records (AWS Flow Logs)

---

## 📊 Key Observations

- MQTT requires protocol-aware inspection

- IDS alerts provide payload-level visibility

- VPC Flow Logs provide traffic context, not content

- Combining both layers improves detection confidence

---

## 🔍 Threat Model Summary

This platform focuses on detecting threats commonly observed in IoT environments, including:
- Message flooding and denial-of-service attempts
- Malformed or protocol-abusive MQTT payloads
- Oversized message delivery attacks
- Anomalous traffic volume at the network layer

The design intentionally combines payload inspection and flow-level telemetry to reduce false positives and improve investigative context.

---

## 🚧 Limitations & Future Enhancements

- TLS-encrypted MQTT traffic is not inspected at the payload level
- Correlation between IDS alerts and VPC Flow Logs is performed manually
- No automated alerting pipeline (email / Slack) is configured

Future improvements could include:
- MQTT over TLS inspection using broker-side logging
- Automated correlation using Lambda or SIEM enrichment
- Real-time alerting and incident response workflows

---

## 📌 Conclusion

This project demonstrates a layered IoT security monitoring approach, integrating host-based intrusion detection with cloud-native network analysis. By combining Suricata, the Elastic Stack, and AWS VPC Flow Logs, the platform enables effective detection, investigation, and correlation of IoT-based attacks.
