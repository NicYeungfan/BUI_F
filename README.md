# BUI_F
Battery_theory_Ultra_new
# Note: 
The datasets used in this study are not publicly available due to proprietary or confidentiality reasons. Example or mock data can be provided upon request for academic purposes.
# Real-Time 3D Ultrasound Imaging for Lithium-Ion Battery Diagnosis

This repository contains original MATLAB code used in the research manuscript:
**"Real-Time 3D Imaging-Diagnosis of Rechargeable Batteries Based on Physics-informed Ultrasound Model"**  
by Nic Yeung Fan (2025).

---

## 🔍 Description

The code implements a real-time ultrasound imaging system for analyzing the internal dynamics of lithium-ion batteries using a custom-designed Row-Column Addressed (RCA) matrix transducer.

It includes:
- **3D image reconstruction algorithms**
- **Physics-informed B-scan and A-scan processing**
- **SNR analysis** for detecting gas bubble formation and charge-state correlation

---

## 📂 File Overview

| File Name              | Description |
|------------------------|-------------|
| `D3VisualfinalBscanPSF.m` | 3D imaging visualization with PSF correction for B-scan signals |
| `DVisulafinal7PSF.m`      | Visualization script for ultrasound signal using PSF estimation |
| `SNRCal3.m`               | Signal-to-Noise Ratio (SNR) calculation script for A-scan data |
| `LICENSE`                 | License file (MIT License) |
| `README.md`              | This file |

---

## 🧪 Sample Data

❗ **Note**: The original experimental data (e.g., `.xlsx`, `.bin`, or `.mat` files) is **not included** in this repository due to proprietary and confidentiality restrictions.  
To test the code, users can simulate or generate synthetic data following the structure referenced in the code.

If needed, you may contact the author to request example data for academic purposes only.

---

## 📋 Requirements

- MATLAB R2021a or later
- Image Processing Toolbox (for visualization functions)
- Optional: Signal Processing Toolbox

---

## 🚀 How to Use

1. Clone this repository:
   ```bash
   git clone https://github.com/NicYeungfan/NicYeungfan.git

