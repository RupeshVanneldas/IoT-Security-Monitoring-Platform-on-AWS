-- ============================================================
-- Project: IoT Security Monitoring and Attack Analysis Platform
-- Component: Part 4 – VPC Flow Log Analysis using Amazon Athena
-- Author: Rupesh Vanneldas
-- Course: CYT160
-- ============================================================

-- NOTE:
-- These queries were executed against AWS VPC Flow Logs stored in S3.
-- The goal is to correlate network-level telemetry with IDS alerts
-- generated in Part 3 (Suricata MQTT inspection).
-- ============================================================


-- ------------------------------------------------------------
-- 1. Verify that VPC Flow Logs are being ingested correctly
-- ------------------------------------------------------------
-- Purpose:
-- Confirms that logs are present and readable by Athena.

SELECT *
FROM vpc_flow_logs
LIMIT 20;


-- ------------------------------------------------------------
-- 2. Identify all traffic targeting the MQTT broker (port 1883)
-- ------------------------------------------------------------
-- Purpose:
-- Establishes baseline visibility of MQTT traffic at the
-- network layer.

SELECT
    srcaddr,
    dstaddr,
    srcport,
    dstport,
    protocol,
    packets,
    bytes,
    action,
    log_status
FROM vpc_flow_logs
WHERE dstport = 1883
ORDER BY start DESC
LIMIT 50;


-- ------------------------------------------------------------
-- 3. Detect high-volume MQTT traffic (potential flooding)
-- ------------------------------------------------------------
-- Purpose:
-- Correlates with Suricata threshold-based alerts for
-- MQTT publish flooding or DoS-style behavior.

SELECT
    srcaddr,
    dstaddr,
    dstport,
    SUM(packets) AS total_packets,
    SUM(bytes) AS total_bytes
FROM vpc_flow_logs
WHERE dstport = 1883
GROUP BY srcaddr, dstaddr, dstport
ORDER BY total_packets DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 4. Identify repeated connections from the same source IP
-- ------------------------------------------------------------
-- Purpose:
-- Highlights suspicious clients repeatedly initiating
-- MQTT connections, often seen during attack simulations.

SELECT
    srcaddr,
    COUNT(*) AS connection_attempts
FROM vpc_flow_logs
WHERE dstport = 1883
GROUP BY srcaddr
ORDER BY connection_attempts DESC
LIMIT 10;


-- ------------------------------------------------------------
-- 5. Detect rejected or abnormal traffic
-- ------------------------------------------------------------
-- Purpose:
-- Identifies traffic that was not accepted, helping validate
-- security enforcement or misconfigured clients.

SELECT
    srcaddr,
    dstaddr,
    dstport,
    action,
    COUNT(*) AS event_count
FROM vpc_flow_logs
WHERE action != 'ACCEPT'
GROUP BY srcaddr, dstaddr, dstport, action
ORDER BY event_count DESC;


-- ------------------------------------------------------------
-- 6. Time-based analysis of MQTT traffic volume
-- ------------------------------------------------------------
-- Purpose:
-- Used to visualize traffic spikes during attack simulations
-- and correlate them with Suricata alert timestamps.

SELECT
    from_unixtime(start) AS flow_start_time,
    dstport,
    packets,
    bytes
FROM vpc_flow_logs
WHERE dstport = 1883
ORDER BY start DESC
LIMIT 50;


-- ------------------------------------------------------------
-- 7. Cross-port comparison (MQTT vs other services)
-- ------------------------------------------------------------
-- Purpose:
-- Demonstrates that abnormal traffic patterns are isolated
-- to MQTT rather than general network noise.

SELECT
    dstport,
    SUM(packets) AS total_packets,
    SUM(bytes) AS total_bytes
FROM vpc_flow_logs
GROUP BY dstport
ORDER BY total_packets DESC;


-- ------------------------------------------------------------
-- End of Athena Queries
-- ============================================================
-- These queries provide a foundational analysis of VPC Flow Logs
-- in the context of IoT security monitoring, specifically
-- focusing on MQTT traffic patterns and potential attack indicators.
-- Further analysis can be built upon these queries to enhance
-- threat detection and response strategies.
-- ============================================================