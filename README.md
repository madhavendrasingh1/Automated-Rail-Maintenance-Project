# 🚆 Automated Rail Maintenance Project

A hybrid anomaly detection framework for **structural health monitoring** of railway tracks using **multi-sensor fusion**. This project focuses on real-time detection of track defects by integrating data from various sensors using temporal and spatial models.

---

## 📌 Project Highlights

- **Sensors Used**: Fiber Optic, Vibration, Ultrasonic, Temperature, Humidity  
- **Approach**: Hybrid deep learning (LSTM + CNN)  
- **Fusion Strategy**: Sensor-level and cross-sensor fusion  
- **Goal**: Identify anomalies like cracks, corrosion, voids, and weld failures to enable predictive maintenance

---

## 🧠 Working Methodology

### 1. Sensor Data Acquisition
Data is collected from 5 types of sensors:
- 💡 Fiber Optic
- 📉 Vibration
- 📡 Ultrasonic
- 🌡️ Temperature
- 💧 Humidity

### 2. Data Synchronization
- **Temporal Alignment**: Resample all sensor data to a common time window (e.g., every 10 seconds).
- **Spatial Alignment**: Bin the railway track into 100-meter segments using chainage or GPS+ICP for spatial consistency.

### 3. Feature Extraction & Modeling
- **Temporal Modeling**: LSTM or GRU networks extract sequential features.
- **Spatial Modeling**: 1D CNNs are applied to localized (segment-wise) data.
- **Model Training**: Each sensor's data is processed and modeled independently before fusion.

### 4. Anomaly Scoring & Fusion
- **Per Sensor Fusion**: Temporal + spatial scores fused using Bayesian inference.
- **Cross-Sensor Fusion**: Final anomaly score computed using ensemble techniques (e.g., weighted voting, stacking).

---
