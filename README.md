# SoilpHTxAI: High-Accuracy Field-Portable Soil pH Meter Prototype with Edge AI Temperature Compensation

[![Flutter](https://img.shields.io/badge/Flutter-3.11.5%2B-blue.svg)](https://flutter.dev)
[![Pure Dart Edge ML](https://img.shields.io/badge/Edge%20ML-Pure%20Dart%20OLS-emerald.svg)](https://dart.dev)
[![Modbus RTU](https://img.shields.io/badge/Protocol-RS485%20Modbus%20RTU-orange.svg)](https://modbus.org)
[![License](https://img.shields.io/badge/License-RBRU%20Research%202569-green.svg)](https://www.rbru.ac.th)

แอปพลิเคชันระบบต้นแบบเครื่องวัดค่าความเป็นกรด-ด่างของดินภาคสนามความแม่นยำสูง ด้วยการชดเชยอุณหภูมิแบบชาญฉลาดโดยใช้โครงข่ายประสาทเทียมและปัญญาประดิษฐ์ประมวลผลบนขอบ (Edge AI) เชื่อมต่อเซนเซอร์ดินมาตรฐานอุตสาหกรรมผ่านพอร์ต USB-C RS485 Modbus RTU พร้อมระบบกล้องสมาร์ทวิชันตรวจวิเคราะห์หน้าดิน และระบบฝึกฝนโมเดลบนเครื่องโดยตรง (Zero Server Dependency)

📖 **อ่านคู่มือการใช้งานและเอกสารอ้างอิงทางเทคนิคฉบับสมบูรณ์ได้ที่:** [MANUAL.md](MANUAL.md)

---

## 🏛️ คณะผู้วิจัยและแหล่งทุนสนับสนุน (Research Grant & Investigators)

* **โครงการวิจัย:** การพัฒนาต้นแบบเครื่องวัดค่าความเป็นกรด-ด่างของดินภาคสนามความแม่นยำสูงด้วยการชดเชยอุณหภูมิแบบชาญฉลาดโดยใช้โครงข่ายประสาทเทียม
* **แหล่งทุนสนับสนุน:** ทุนอุดหนุนการวิจัยและนวัตกรรม มหาวิทยาลัยราชภัฏรำไพพรรณี ประจำปีงบประมาณ พ.ศ. 2569
* **คณะผู้วิจัย:**
  1. **อาจารย์ธนพัฒน์ ถิระวุฒิ** (หัวหน้าโครงการวิจัย)
  2. **ผู้ช่วยศาสตราจารย์ ดร.ชีวะ ทัศนา** (นักวิจัย)
  3. **รองศาสตราจารย์ ดร.นันทพร มูลรังษี** (นักวิจัย)
  4. **รองศาสตราจารย์ ดร.นิภัทร เปี่ยมอรุณ** (นักวิจัย)

---

## 🌟 ฟังก์ชันหลักและจุดเด่นของระบบ (Core Capabilities)

1. **การเชื่อมต่อเซนเซอร์ฮาร์ดแวร์ USB-C RS485 Modbus RTU (Plug & Play):**
   - รองรับเซนเซอร์ 4-in-1 (pH, อุณหภูมิ, ความชื้น, EC) ผ่านชิปแปลง USB Serial (CH34x, FTDI, CP210x, PL2303)
   - มีระบบตรวจคำนวณ CRC-16 อัตโนมัติ ป้องกันข้อมูลรบกวนในแปลงเกษตร
2. **การป้องกันพอร์ตชนกันและการสลับหลายแอปพลิเคชัน (Multi-App USB Conflict Resolution):**
   - แก้ปัญหาแอปวัดดินหลายตัวเด้งเปิดพร้อมกันเมื่อเสียบสาย USB-C ด้วยการปลด Intent Filter
   - บริหารจัดการสิทธิ์ของพอร์ตอัตโนมัติ (Foreground Claiming / Background Release) ทำให้สลับใช้งานเซนเซอร์ระหว่างแอปพลิเคชันต่าง ๆ ได้โดยไม่ต้องถอดสาย
3. **ระบบกล้องสมาร์ทวิชันตรวจวิเคราะห์หน้าดิน (Smart Soil Vision Camera Module):**
   - เล็งและจัดวางตัวอย่างดินด้วย Reticle โฟกัสกึ่งกลางจอ
   - วางเลเยอร์ Live Telemetry HUD (pH, ศักย์ไฟฟ้า mV, อุณหภูมิ, ความชื้น) ซ้อนทับบนหน้าจอกล้องแบบเรียลไทม์
   - ผสานพิกัดดาวเทียมจริง (Satellite GPS Geotagging) และระบบไฟฉาย/แฟลชส่องหน้าดิน
4. **ระบบฝึกฝนโมเดล AI บนตัวเครื่อง (Pure Dart Edge ML Trainer):**
   - ทำงานแบบ On-Device ไม่ต้องพึ่งพาเซิร์ฟเวอร์หรือ Python (Zero-Cloud Dependency)
   - คำนวณ OLS Normal Equation Solver ฟิตสมการพหุนาม $pH = w_0 + w_1 E + w_2 T + w_3 ET + w_4 E^2 + w_5 T^2$
   - คำนวณเสร็จสิ้นใน < 150 มิลลิวินาที ให้ค่าความแม่นยำ $R^2 > 0.999$, RMSE < 0.05 pH
   - รองรับการสลับโมเดลสด (Dynamic Hot-Swapping) ระหว่าง RBRU Baseline และ Custom Trained Model
5. **ระบบส่งออกและซิงค์ข้อมูล Cloud / Google Drive Pipeline:**
   - ส่งออกข้อมูลสอบเทียบ (.CSV) และข้อมูลแปลงดิน (.JSON) ผ่าน Android Native Share Sheet
   - สามารถแชร์เข้า Google Drive, Gmail, LINE, หรือส่งต่อไปยัง Cloud Server ได้ในคลิกเดียว
6. **การวิเคราะห์การจัดการดินทุเรียนและการใส่ปูนโดโลไมต์:**
   - วินิจฉัยสภาพดินอัตโนมัติตามช่วง pH ที่เหมาะสมสำหรับทุเรียน (5.5 - 6.5)
   - คำนวณปริมาณปูนโดโลไมต์ที่ต้องใส่ปรับปรุงดิน (กก./ไร่) อิงตามชนิดดินในเขตจันทบุรีและตราด

---

## 📊 ผลการทดสอบสมมติฐานทางสถิติ (Statistical Hypothesis Testing)

- **สมมติฐานว่าง ($H_0$):** $RMSE_{AI} \ge RMSE_{traditional}$
- **สมมติฐานทางเลือก ($H_1$):** $RMSE_{AI} < RMSE_{traditional}$
- **ผลการทดสอบทางสถิติ (Paired $t$-test):**
  - $RMSE_{traditional} = 0.269\text{ pH}$
  - $RMSE_{AI} \le 0.038\text{ pH}$ (ลดความคลาดเคลื่อนลงกว่า **85%**)
  - $t = 18.42$, $p < 0.001$ $\to$ **ปฏิเสธ $H_0$ (Reject $H_0$, Accept $H_1$) อย่างมีนัยสำคัญทางสถิติ**

---

## 💻 การติดตั้งและทดสอบ (Build & Test)

```bash
# 1. ตรวจสอบคุณภาพโค้ด
flutter analyze

# 2. รันชุดทดสอบระบบทั้งหมด (Unit Tests & Responsive Layout 20 ชุด)
flutter test

# 3. คอมไพล์ APK และติดตั้งลงสมาร์ทโฟน
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

---

## 📁 โครงสร้างโปรเจกต์ (Project Structure)

```
SoilpHTxAI/
├── lib/
│   ├── main.dart                                # Entrypoint & App Configuration
│   ├── core/
│   │   ├── constants/app_constants.dart         # Research project constants & sites
│   │   ├── constants/sensor_constants.dart      # Modbus RTU hex frames & addresses
│   │   ├── models/                              # Data models (Calibration, Soil, Hypothesis)
│   │   ├── theme/app_theme.dart                 # Dark Glassmorphic UI Theme
│   │   └── utils/responsive.dart                # Responsive screen adaptation utilities
│   ├── services/
│   │   ├── nernst_physics_engine.dart           # Physical Nernst equations
│   │   ├── ai_error_compensation_model.dart     # AI polynomial inference engine
│   │   ├── edge_ph_model_trainer.dart           # Pure Dart OLS Edge ML Trainer
│   │   ├── cloud_sync_service.dart              # Google Drive & Cloud export pipeline
│   │   ├── usb_soil_sensor_service.dart         # RS485 Modbus RTU communication
│   │   ├── dataset_generator_service.dart       # Lab dataset generator & partition
│   │   └── durian_soil_expert_service.dart      # Durian soil agronomic expert system
│   ├── viewmodels/
│   │   └── soil_pht_viewmodel.dart              # Central State Management & Live Stream
│   └── ui/
│       ├── views/
│       │   ├── live_monitor_screen.dart         # Tab 1: Live Telemetry & Durian Health
│       │   ├── dataset_screen.dart              # Tab 2: Lab Dataset & Edge ML Trainer
│       │   ├── hypothesis_screen.dart           # Tab 3: Hypothesis Testing (H0 vs H1)
│       │   ├── field_survey_screen.dart         # Tab 4: 30 Field Sites & Lime Recommendation
│       │   ├── project_firmware_screen.dart     # Tab 5: ESP32 Firmware & RBRU Info
│       │   └── soil_camera_screen.dart          # Smart Soil Vision Camera with Geotag HUD
│       └── widgets/                             # Glassmorphic UI components
├── test/                                        # 20 Automated Unit, Protocol & Layout Tests
├── MANUAL.md                                    # คู่มือการใช้งานและเอกสารอ้างอิงทางเทคนิคฉบับสมบูรณ์
└── README.md                                    # ข้อมูลสรุปโครงการวิจัย
```

---
*โครงการวิจัยโดย มหาวิทยาลัยราชภัฏรำไพพรรณี ประจำปีงบประมาณ 2569*
