# 🚆 Hybrid Anomaly Detection Framework for Railway Track Monitoring

This repository implements a **hybrid anomaly detection framework** that fuses multi-sensor data to detect anomalies on railway tracks. It integrates **temporal and spatial synchronization**, **sensor-specific models**, and **Bayesian fusion techniques**.

---

## 📌 Overview

Different types of sensors collect data at varying sampling rates and positions:

| Sensor Type           | Sampling Rate       |
|------------------------|---------------------|
| Fiber Optic Strain     | 1000 Hz             |
| Ultrasonic (ToF)       | 1 Hz                |
| Vibration Accelerometer| 5000 Hz             |
| Temperature            | Every 10 seconds    |
| Humidity               | Every 60 seconds    |

This framework synchronizes all data into unified temporal-spatial windows for efficient anomaly detection.

---

## 🧱 System Architecture

### **Step 1: Input Layer — Raw Sensor Data Acquisition**

Collect raw time-series sensor data with corresponding positions.

---

### **Step 2: Synchronization Layer**

#### ✅ Temporal Synchronization

- Convert raw streams into fixed time windows (e.g., every 10 seconds).
- Use aggregation functions like `mean`, `min`, `max`, `median`, and `mode`.

Example in Python:

```python
fiber_df = fiber_df.resample('10s').agg(['mean', 'median', 'min', 'max'])
vibration_df = vibration_df.resample('10s').agg(['mean'])
ultrasonic_df = ultrasonic_df.resample('10s').mean()
temp_df = temp_df.resample('10s').mean()
humidity_df = humidity_df.resample('10s').mean()
