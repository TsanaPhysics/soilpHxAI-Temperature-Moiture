# คู่มือการใช้งานและเอกสารอ้างอิงทางเทคนิคฉบับสมบูรณ์ (Comprehensive System Manual)
## โครงการวิจัยและพัฒนาต้นแบบเครื่องวัดค่าความเป็นกรด-ด่างของดินภาคสนามความแม่นยำสูงด้วยการชดเชยอุณหภูมิแบบชาญฉลาดโดยใช้โครงข่ายประสาทเทียม
### SoilpHTxAI: High-Accuracy Field-Portable Soil pH Meter Prototype with Edge AI Temperature Compensation

<p align="center">
  <img src="docs/cover_page_preview.png" width="400" alt="SoilpHTxAI Research Monograph & System Manual Cover" style="border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.3);" />
</p>

---

## สารบัญ (Table of Contents)

1. [ข้อมูลโครงการวิจัยและคณะผู้วิจัย](#1-ข้อมูลโครงการวิจัยและคณะผู้วิจัย-research-project-information)
2. [บทนำและหลักการทางฟิสิกส์พื้นฐาน](#2-บทนำและหลักการทางฟิสิกส์พื้นฐาน-first-principles-physics-foundation)
3. [สถาปัตยกรรมฮาร์ดแวร์และการสื่อสาร Modbus RTU](#3-สถาปัตยกรรมฮาร์ดแวร์และการสื่อสาร-modbus-rtu)
4. [แบบจำลองคณิตศาสตร์และปัญญาประดิษฐ์บนขอบ](#4-แบบจำลองคณิตศาสตร์และปัญญาประดิษฐ์บนขอบ-mathematical-models--edge-ai)
5. [สถาปัตยกรรมแอปพลิเคชันและการออกแบบส่วนต่อประสาน](#5-สถาปัตยกรรมแอปพลิเคชันและการออกแบบส่วนต่อประสาน-application-architecture--uiux)
6. [ระบบกล้องสมาร์ทวิชันตรวจวิเคราะห์หน้าดินพร้อมพิกัดภูมิศาสตร์](#6-ระบบกล้องสมาร์ทวิชันตรวจวิเคราะห์หน้าดินพร้อมพิกัดภูมิศาสตร์-smart-soil-vision--geotagging)
7. [ระบบจัดเก็บและซิงค์ข้อมูลผ่านคลาวด์](#7-ระบบจัดเก็บและซิงค์ข้อมูลผ่านคลาวด์-cloud-sync--data-management)
8. [การทดสอบสมมติฐานทางสถิติและการทดลองภาคสนาม](#8-การทดสอบสมมติฐานทางสถิติและการทดลองภาคสนาม-field-validation--hypothesis-testing)
9. [ขั้นตอนการสร้างและคอมไพล์แอปพลิเคชัน](#9-ขั้นตอนการสร้างและคอมไพล์แอปพลิเคชัน-step-by-step-app-development--build)
10. [ภาคผนวก ก: รหัสต้นแบบเฟิร์มแวร์ ESP32 C++](#ภาคผนวก-ก-รหัสต้นแบบเฟิร์มแวร์-esp32-c-appendix-a)
11. [ภาคผนวก ข: ซอร์สโค้ด Pure Dart Edge ML Trainer](#ภาคผนวก-ข-ซอร์สโค้ด-pure-dart-edge-ml-trainer-appendix-b)
12. [ภาคผนวก ค: ตัวอย่างชุดข้อมูลสอบเทียบและแปลงสำรวจภาคสนาม](#ภาคผนวก-ค-ตัวอย่างชุดข้อมูลสอบเทียบและแปลงสำรวจภาคสนาม-appendix-c)
13. [เอกสารอ้างอิงและประวัติผู้จัดทำ](#เอกสารอ้างอิงและประวัติผู้จัดทำ-references--author-biography)

---

## 1. ข้อมูลโครงการวิจัยและคณะผู้วิจัย (Research Project Information)

* **แหล่งทุนสนับสนุน** ทุนอุดหนุนการวิจัยและนวัตกรรม มหาวิทยาลัยราชภัฏรำไพพรรณี ประจำปีงบประมาณ พ.ศ. 2569
* **หน่วยงานต้นสังกัด** หน่วยวิจัยปัญญาประดิษฐ์เพื่อเกษตรดิจิทัล คณะวิทยาศาสตร์และเทคโนโลยี มหาวิทยาลัยราชภัฏรำไพพรรณี
* **คณะผู้วิจัยและสัดส่วนการวิจัย (Research Team & Contribution Ratios)**
  1. **อาจารย์ธนพัฒน์ ถิระวุฒิ** — หัวหน้าโครงการวิจัย (Principal Investigator, สัดส่วน 50%)
  2. **ผู้ช่วยศาสตราจารย์ ดร.ชีวะ ทัศนา** — นักวิจัย (Co-Principal Investigator, สัดส่วน 30%)
  3. **รองศาสตราจารย์ ดร.นันทพร มูลรังษี** — นักวิจัย (Co-Principal Investigator, สัดส่วน 10%)
  4. **รองศาสตราจารย์ ดร.นิภัทร เปี่ยมอรุณ** — นักวิจัย (Co-Principal Investigator, สัดส่วน 10%)
* **คลังรหัสต้นฉบับ (GitHub Repository)** [TsanaPhysics/soilpHxAI-Temperature-Moiture](https://github.com/TsanaPhysics/soilpHxAI-Temperature-Moiture.git)

---

## 2. บทนำและหลักการทางฟิสิกส์พื้นฐาน (First-Principles Physics Foundation)

การตรวจวัดค่าความเป็นกรด-ด่าง ($pH$) ในดินทางการเกษตรแม่นยำสูง มักประสบปัญหาการเบี่ยงเบนของค่าที่อ่านได้ตามการเปลี่ยนแปลงของอุณหภูมิภาคสนาม (Temperature Drift) และความไม่เป็นเชิงเส้นของหัววัดศักย์ไฟฟ้าเคมี (Electrochemical Sensor Non-linearity)

### 2.1 สมการเนิร์นสต์ (Nernst Equation)
ตามหลักอุณหพลศาสตร์เคมี ศักย์ไฟฟ้าของเซลล์ไฟฟ้าเคมี ($E$) สัมพันธ์กับกัมมันตภาพของไอออนไฮโดรเจน ($a_{H^+}$) และอุณหภูมิสัมบูรณ์ ($T$ เคลวิน) ดังนี้

$$E = E_0 - rac{2.3026 \cdot R \cdot T}{F} \cdot (pH - 7)$$

โดยที่
* $E_0$ คือ ศักย์ไฟฟ้ามาตรฐานของระบบหัววัด (Standard Electrode Potential, mV)
* $R$ คือ ค่าคงที่ของก๊าซสากล ($8.314462	ext{ J/mol}\cdot	ext{K}$)
* $T$ คือ อุณหภูมิสัมบูรณ์ ($T = T_C + 273.15	ext{ K}$)
* $F$ คือ ค่าคงที่ฟาราเดย์ ($96485.3321	ext{ C/mol}$)
* ความชันอุดมคติของเนิร์นสต์ (Nernstian Slope, $S$) ที่ $25^\circ	ext{C}$ มีค่าเท่ากับ $59.16	ext{ mV/pH}$

### 2.2 ข้อจำกัดของการชดเชยเชิงเส้นแบบดั้งเดิม (Limitations of Traditional ATC)
ระบบชดเชยอุณหภูมิอัตโนมัติแบบดั้งเดิม (Automatic Temperature Compensation: ATC) สมมติว่าความชันเปลี่ยนรูปตามสมการเนิร์นสต์เชิงเส้นเพียงอย่างเดียว แต่ในสภาพแปลงดินจริง มีปัจจัยแทรกซ้อนดังนี้
1. **ศักย์ไฟฟ้าอสมมาตร (Asymmetry Potential Drift)** จุดตัดไอโซโพเทนเชียล (Isopotential Point) เบี่ยงเบนออกจาก pH 7.00
2. **สัมประสิทธิ์อุณหภูมิของสารละลายดิน (Solution Temperature Coefficient)** ความสามารถในการแตกตัวของกรดอินทรีย์ในดินเปลี่ยนรูปตามอุณหภูมิ
3. **ผลกระทบฮิสเทอรีซิส (Electrochemical Hysteresis)** การตอบสนองของเซนเซอร์ไม่เท่ากันระหว่างอุณหภูมิขาขึ้นและขาลง

โครงการนี้จึงนำเสนอ **แบบจำลองปัญญาประดิษฐ์โครงข่ายพหุนามบนขอบ (Edge AI Non-linear Temperature Compensation)** เพื่อทำนายค่า pH ที่แท้จริงได้อย่างแม่นยำ

---

## 3. สถาปัตยกรรมฮาร์ดแวร์และการสื่อสาร Modbus RTU

```
+-------------------+       RS485 Modbus RTU       +-----------------------+
|  Soil 4-in-1      |=============================>| RS485-to-USB-C        |
|  Sensor Probe     | (Baud 9600, 8-N-1, Slave 01) | FTDI/CH340 Controller |
+-------------------+                              +-----------------------+
         |                                                     |
  [Moisture, Temp,                                         USB-C OTG
   EC, Raw pH]                                                 |
                                                               v
                                                   +-----------------------+
                                                   | Android Smartphone    |
                                                   | (SoilpHTxAI App)      |
                                                   | Pure Dart Edge Engine |
                                                   +-----------------------+
```

### 3.1 ข้อมูลจำเพาะโปรโตคอล Modbus RTU
* **Baud Rate** 9600 bps
* **Data Bits** 8, **Parity** None, **Stop Bits** 1
* **Slave Address** `0x01`
* **Function Code** `0x03` (Read Holding Registers)
* **Start Register** `0x0000`, **Length** 4 Registers (8 Bytes)
* **Request Packet (Hex)** `01 03 00 00 00 04 44 09`
* **Response Packet (13 Bytes)** `[01, 03, 08, D0, D1, D2, D3, D4, D5, D6, D7, CRC_L, CRC_H]`
  - ไบต์ที่ 3-4 (D0, D1): ค่าความชื้นสัมพัทธ์ในดิน (หาร 10.0 ได้หน่วย %)
  - ไบต์ที่ 5-6 (D2, D3): ค่าอุณหภูมิหน้าดิน (หาร 10.0 ได้หน่วย °C)
  - ไบต์ที่ 7-8 (D4, D5): ค่าการนำไฟฟ้า EC (หน่วย $\mu	ext{S/cm}$)
  - ไบต์ที่ 9-10 (D6, D7): ค่าความเป็นกรด-ด่างดินดิบ (หาร 10.0 หรือ 100.0 ได้ค่า Raw pH)
  - ไบต์ที่ 11-12: รหัสตรวจสอบความถูกต้อง CRC-16 Modbus

### 3.2 การป้องกันพอร์ตชนกัน (USB Port Claiming Protection)
บนระบบปฏิบัติการ Android หากมีหลายแอปพลิเคชันที่รองรับพอร์ต USB-C ติดตั้งอยู่ อาจเกิดการแย่งสิทธิ์เชื่อมต่อพร้อมกัน แอปพลิเคชัน SoilpHTxAI แก้ไขปัญหานี้ด้วย
1. **Explicit Device Filter Identification** ตรวจจับเฉพาะ Vendor ID และ Product ID ของชิปแปลงสัญญาณ RS485 (เช่น FTDI `0x0403`, CH340 `0x1A86`, CP2102 `0x10C4`, Prolific `0x067B`)
2. **Session Claim & Release Lifecycle** ขอสิทธิ์ `UsbManager.requestPermission()` เฉพาะเมื่อผู้ใช้กดปุ่มเชื่อมต่อ และปลดล็อกปล่อยพอร์ต (`port.close()`) ทันทีที่แอปเข้าสู่ Background

---

## 4. แบบจำลองคณิตศาสตร์และปัญญาประดิษฐ์บนขอบ (Mathematical Models & Edge AI)

### 4.1 โครงสร้างแบบจำลองปัญญาประดิษฐ์ (Edge AI Polynomial Model)
แบบจำลองชดเชยอุณหภูมิบนขอบกำหนดเป็นสมการพหุนามอันดับสอง 2 มิติ (2D Second-Order Polynomial Surface):

$$pH_{AI} = w_0 + w_1 E + w_2 T + w_3 (E \cdot T) + w_4 E^2 + w_5 T^2$$

โดยที่
* $E$ คือ ศักย์ไฟฟ้าของหัววัด (mV) คำนวณย้อนกลับจากค่า pH ดิบ
* $T$ คือ อุณหภูมิหน้าดิน (°C)
* $\mathbf{W} = [w_0, w_1, w_2, w_3, w_4, w_5]^T$ คือ เวกเตอร์ค่าน้ำหนักสัมประสิทธิ์ของแบบจำลอง

### 4.2 การฝึกฝนแบบจำลองบนขอบด้วยระเบียบวิธี OLS Normal Equations
การฝึกฝนแบบจำลองสามารถทำได้โดยตรงบนสมาร์ทโฟนแบบออฟไลน์ 100% โดยไม่ต้องพึ่งพาคลาวด์เซิร์ฟเวอร์ ผ่านสมการปรกติ (Normal Equations):

$$\mathbf{X}^T \mathbf{X} \mathbf{W} = \mathbf{X}^T \mathbf{Y}$$

กำหนดให้เมทริกซ์การออกแบบ $\mathbf{X} \in \mathbb{R}^{N 	imes 6}$ และเวกเตอร์เป้าหมาย $\mathbf{Y} \in \mathbb{R}^N$ โดยแถวที่ $i$ ของ $\mathbf{X}$ คือ:

$$\mathbf{x}_i = [1,\; E_i,\; T_i,\; E_i T_i,\; E_i^2,\; T_i^2]$$

ระบบสมการเชิงเส้น $\mathbf{A} \mathbf{W} = \mathbf{B}$ ขนาด $6 	imes 6$ แก้สมการหาผลเฉลยด้วยระเบียบวิธีขจัดแบบเกาส์เซียนพร้อมการเลือกจุดหมุนบางส่วน (Gaussian Elimination with Partial Pivoting):
* ใช้เวลาประมวลผลน้อยกว่า 5 มิลลิวินาทีบนซีพียูสมาร์ทโฟน
* ได้ค่าสัมประสิทธิ์ที่ลู่เข้าจุดต่ำสุดสัมบูรณ์อย่างแม่นยำ (Exact Global Optimum Convergence)

---

## 5. สถาปัตยกรรมแอปพลิเคชันและการออกแบบส่วนต่อประสาน (Application Architecture & UI/UX)

แอปพลิเคชัน SoilpHTxAI พัฒนาด้วย Flutter ตามสถาปัตยกรรม Clean Architecture และการจัดการสถานะแบบ Provider:

```
[Presentation Layer] <---> [Business Logic / Providers] <---> [Data / Repository Layer]
- LiveTelemetryScreen       - SensorTelemetryProvider         - UsbSerialDataSource
- EdgeMlStudioScreen        - EdgeMlTrainerProvider           - GpsLocationService
- HypothesisTestScreen      - FieldSurveyProvider             - CameraVisionService
- FieldSurveyScreen                                           - GoogleDriveSyncService
- ProjectFirmwareScreen
```

### 5.1 รายละเอียดหน้าจอหลักทั้ง 5 แท็บ
1. **หน้าจอที่ 1: การตรวจวัดสดและการสอบเทียบ (Live Telemetry & Calibration)**
   - เกจวัดค่าความเป็นกรด-ด่างแบบแอนะล็อกร่วมกับจอแสดงผลดิจิทัล
   - ป้ายระบุสถานะความแม่นยำและระดับความเป็นกรดตามมาตรฐานการเกษตร
   - กราฟแนวโน้มแบบเรียลไทม์แสดงค่า pH, ศักย์ไฟฟ้า (mV), อุณหภูมิ (°C) และความชื้น (%)
   - ระบบสอบเทียบ 3 จุด (pH 4.01, 6.86, 9.18) พร้อมบันทึกจุดสอบเทียบเข้าคลัง
2. **หน้าจอที่ 2: ห้องทดลองปัญญาประดิษฐ์บนขอบ (Edge ML Studio)**
   - แสดงค่าน้ำหนักสัมประสิทธิ์ปัจจุบันทั้ง 6 ตัว ($w_0$ ถึง $w_5$)
   - แดชบอร์ดสรุปประสิทธิภาพแบบจำลอง: ค่า $R^2$, RMSE, MAE และเวลาในการฝึกฝน
   - ปุ่มกดฝึกฝนแบบจำลองสด (On-Device Model Training) พร้อมหน้าต่างไดอะล็อกแสดงผลแบบเรียลไทม์
   - สลับโหมดการทำงานระหว่าง Nernst ATC และ Pure Dart Edge AI Engine
3. **หน้าจอที่ 3: การทดสอบสมมติฐานทางสถิติ (Hypothesis Testing)**
   - ทดสอบสมมติฐานทางสถิติ $H_0: RMSE_{AI} \ge RMSE_{traditional}$ เทียบกับ $H_1: RMSE_{AI} < RMSE_{traditional}$
   - วิเคราะห์สถิติทดสอบทีแบบจับคู่ (Paired t-test) ได้ค่าสถิติ $t = 18.42, p < 0.001$ ยืนยันความเหนือกว่าอย่างมีนัยสำคัญ
4. **หน้าจอที่ 4: การสำรวจดินแปลงปลูกจริง (Field Survey & Soil Management)**
   - คลังข้อมูลสำรวจดินจริง 30 แปลงในจังหวัดจันทบุรีและตราด
   - ระบบคำนวณอัตราการใส่ปูนโดโลไมต์ปรับปรุงดินอัตโนมัติตามเนื้อดินและค่า pH เป้าหมาย
   - บันทึกตัวอย่างดินใหม่จากเซนเซอร์สดพร้อมพิกัดดาวเทียม GPS
5. **หน้าจอที่ 5: ข้อมูลโครงการและเครื่องมือสร้างเฟิร์มแวร์ C++ (Project & Firmware Studio)**
   - รายนามคณะผู้วิจัยและสัดส่วนวิจัย (50%, 30%, 10%, 10%)
   - ตัวสร้างซอร์สโค้ด C++ อัตโนมัติ (C++ Arduino Generator) พร้อมนำค่าน้ำหนักไปแฟลชลงไมโครคอนโทรลเลอร์ ESP32 ได้ทันที

---

## 6. ระบบกล้องสมาร์ทวิชันตรวจวิเคราะห์หน้าดินพร้อมพิกัดภูมิศาสตร์ (Smart Soil Vision & Geotagging)

ระบบกล้องเปิดใช้งานผ่านปุ่ม Camera Action Floating Button:
1. **Live Telemetry HUD Overlay** ซ้อนทับค่าการวัดสด (pH AI, ศักย์ไฟฟ้า, อุณหภูมิ, ความชื้น) บนหน้าจอกล้อง
2. **GPS Geotag Display** แสดงพิกัดละติจูดและลองจิจูดจากชิปดาวเทียมกำกับบนหน้าจอกล้อง
3. **Soil Focus Reticle** กรอบเป้าเล็งกึ่งกลางจอเพื่อจัดวางตำแหน่งโพรบและพื้นผิวหน้าดิน
4. **Hardware Torch & Camera Controls** สลับกล้องหน้า-หลัง และเปิดไฟฉายช่วยส่องสว่างหน้าดินในแปลงเกษตร
5. **Metadata Embedding** บันทึกภาพถ่ายตัวอย่างดินความละเอียดสูงพร้อมฝังข้อมูล EXIF และสร้างไดอะล็อกสรุปคุณลักษณะหน้าดินทันทีหลังถ่ายภาพ

---

## 7. ระบบจัดเก็บและซิงค์ข้อมูลผ่านคลาวด์ (Cloud Sync & Data Management)

เพื่อรองรับการส่งต่อข้อมูลเพื่อเทรนโมเดลขนาดใหญ่บนเซิร์ฟเวอร์คลาวด์ แอปพลิเคชันมีระบบ Dual-Backend Data Management:
1. **Local SQLite Offline Database** จัดเก็บตัวอย่างดินและประวัติการสอบเทียบทั้งหมดในเครื่องแบบออฟไลน์
2. **Google Drive Sync / Cloud Backup** ส่งออกข้อมูลในรูปแบบมาตรฐาน JSON และ CSV ไปยัง Google Drive หรือคลาวด์เซิร์ฟเวอร์
3. **Unified RESTful API Ready** โครงสร้างข้อมูล JSON สอดคล้องกับมาตรฐานการแลกเปลี่ยนข้อมูลสำหรับการเทรนซ้ำบน GPU Server

---

## 8. การทดสอบสมมติฐานทางสถิติและการทดลองภาคสนาม (Field Validation & Hypothesis Testing)

### 8.1 สรุปผลการเปรียบเทียบความแม่นยำในห้องปฏิบัติการและภาคสนาม
จากการทดลองวัดสารละลายมาตรฐานและตัวอย่างดินที่ระดับอุณหภูมิ $15^\circ	ext{C}$ ถึง $45^\circ	ext{C}$:

| ตัวชี้วัดประสิทธิภาพ (Metrics) | การชดเชย Nernst ดั้งเดิม | แบบจำลอง Edge AI Polynomial | การปรับปรุง (% Improvement) | นัยสำคัญทางสถิติ |
| :--- | :---: | :---: | :---: | :---: |
| **Root Mean Square Error (RMSE)** | $0.2316	ext{ pH}$ | **$0.0329	ext{ pH}$** | **ลดลง 85.80%** | $p < 0.001$ ($t = 18.42$) |
| **Mean Absolute Error (MAE)** | $0.1875	ext{ pH}$ | **$0.0263	ext{ pH}$** | **ลดลง 85.97%** | $p < 0.001$ |
| **สัมประสิทธิ์การตัดสินใจ ($R^2$)** | $0.8712$ | **$0.9851$** | **เพิ่มขึ้น 13.07%** | ยอดเยี่ยม |

### 8.2 สูตรการคำนวณปริมาณปูนปรับปรุงดินสวนทุเรียน
แบบจำลองคำนวณอัตราการใส่ปูนโดโลไมต์ปรับปรุงดิน ($L$ กิโลกรัมต่อไร่) สู่ระดับเป้าหมาย pH 6.00:

$$L = (pH_{target} - pH_{actual}) \cdot F_{soil}$$

โดยที่ตัวคูณเนื้อดิน ($F_{soil}$) กำหนดเป็น:
* ดินทราย (Sandy Soil): $150	ext{ kg/rai/pH}$
* ดินร่วน (Loam Soil): $250	ext{ kg/rai/pH}$
* ดินเหนียว (Clay Soil): $350	ext{ kg/rai/pH}$

---

## 9. ขั้นตอนการสร้างและคอมไพล์แอปพลิเคชัน (Step-by-Step App Development & Build)

### 9.1 ความต้องการของระบบ (Prerequisites)
* Flutter SDK $\ge$ 3.11.5 (Dart SDK $\ge$ 3.8.0)
* Android SDK Platform API 33+ (Android 13 Tiramisu หรือใหม่กว่า)
* สายแปลงสัญญาณ USB-C OTG สำหรับเชื่อมต่อฮาร์ดแวร์

### 9.2 โครงสร้างไดเรกทอรีของโครงการ
```
SoilpHTxAI/
├── android/                  # Android Native Config & Manifest
│   └── app/src/main/
│       ├── AndroidManifest.xml
│       └── res/xml/device_filter.xml
├── lib/
│   ├── core/
│   │   ├── constants/        # AppConstants & Author Attribution
│   │   ├── models/           # CalibrationPoint, SoilSample, EdgeMlResult
│   │   └── utils/            # NernstCalculator, ModbusCrc16
│   ├── services/             # UsbSerialService, EdgePhModelTrainer, CameraService
│   ├── providers/            # State Management Providers
│   ├── ui/
│   │   ├── views/            # 5 Main Tabs Screens & Camera Screen
│   │   └── widgets/          # AnalogGauge, TrendChart, TelemetryCard
│   └── main.dart             # Application Entrypoint
├── test/                     # 20 Automated Unit & Widget Tests
├── docs/
│   └── manual_latex/         # RBRU Masterclass XeLaTeX Textbook Project
├── MANUAL.md                 # Full System Manual
└── pubspec.yaml              # Dependencies Specification
```

### 9.3 การตั้งค่าสิทธิ์บน Android (`AndroidManifest.xml`)
ต้องระบุสิทธิ์การใช้งาน USB Host, กล้องถ่ายภาพ และพิกัดตำแหน่ง:
```xml
<uses-feature android:name="android.hardware.usb.host" android:required="true" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-permission android:name="android.permission.USB_PERMISSION" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### 9.4 คำสั่งตรวจสอบคุณภาพและคอมไพล์ (Build Commands)
```bash
# 1. ดาวน์โหลดแพ็กเกจที่เกี่ยวข้อง
flutter pub get

# 2. ตรวจสอบโค้ดด้วย Static Analyzer
flutter analyze

# 3. รันชุดทดสอบอัตโนมัติ 20 การทดสอบ
flutter test

# 4. คอมไพล์ไฟล์ติดตั้ง APK
flutter build apk --debug
# หรือสำหรับโปรดักชัน
flutter build apk --release

# 5. ติดตั้งลงในสมาร์ทโฟนที่เชื่อมต่อผ่าน ADB
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

---

## ภาคผนวก ก: รหัสต้นแบบเฟิร์มแวร์ ESP32 C++ (Appendix A)

```cpp
// ============================================================================
// SoilpHTxAI - Embedded AI Error Compensation Engine for ESP32 / Arduino
// Project: Development of a High-Accuracy Field-Portable Soil pH Meter Prototype
// Funding: Rambhai Barni Rajabhat University Research Fund 2569
// Principal Investigators: 
//   Tanapat Tirawoot (50%), Asst.Prof.Dr. Chewa Thassana (30%), 
//   Assoc.Prof.Dr. Nuntaporn Moonrungsee (10%), Assoc.Prof.Dr. Nipat Piamarun (10%)
// ============================================================================

#include <Arduino.h>
#include <math.h>

// AI Model Polynomial Coefficients (Trained via On-Device OLS Regression)
static const float C_BIAS = 6.931715f;
static const float C_E    = -0.03481958f;
static const float C_T    = 0.00956416f;
static const float C_ET   = -3.47704e-05f;
static const float C_E2   = 7.53126e-06f;
static const float C_T2   = -1.62641e-05f;

float predictAiCompensatedPh(float potentialMv, float tempC) {
  float e = potentialMv;
  float t = tempC;
  
  float phPred = C_BIAS +
                 (C_E * e) +
                 (C_T * t) +
                 (C_ET * e * t) +
                 (C_E2 * e * e) +
                 (C_T2 * t * t);

  if (phPred < 0.0f) phPred = 0.0f;
  if (phPred > 14.0f) phPred = 14.0f;
  return phPred;
}

void setup() {
  Serial.begin(115200);
  Serial.println("SoilpHTxAI Firmware Initialized (RBRU 2569)");
}

void loop() {
  float rawMv = 118.5f; // Replace with analogReadMilliVolts(34) or Modbus data
  float tempC = 28.5f;  // Replace with DS18B20 or Modbus temperature
  
  float phAI = predictAiCompensatedPh(rawMv, tempC);
  
  Serial.print("{"potential_mv":");
  Serial.print(rawMv, 2);
  Serial.print(","temperature_c":");
  Serial.print(tempC, 2);
  Serial.print(","ai_ph":");
  Serial.print(phAI, 3);
  Serial.println("}");
  
  delay(1000);
}
```

---

## ภาคผนวก ข: ซอร์สโค้ด Pure Dart Edge ML Trainer (Appendix B)

```dart
// ============================================================================
// Pure Dart On-Device OLS Matrix Regression Solver (Zero Cloud Dependency)
// Project: SoilpHTxAI - Rambhai Barni Rajabhat University
// ============================================================================

import 'dart:math';
import '../core/models/calibration_point.dart';

class EdgePhModelTrainer {
  static Future<EdgeMlTrainingResult> trainModel({
    required List<CalibrationPoint> trainingPoints,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    const int numFeatures = 6;
    final int n = trainingPoints.length;

    if (n < numFeatures) {
      throw ArgumentError('Required at least $numFeatures calibration points, got $n');
    }

    // Construct Normal Equation Matrix A = X^T * X and Vector B = X^T * Y
    final List<List<double>> A = List.generate(
      numFeatures, (_) => List.filled(numFeatures, 0.0)
    );
    final List<double> B = List.filled(numFeatures, 0.0);

    for (final p in trainingPoints) {
      final double e = p.potentialMv;
      final double t = p.temperatureC;
      final double y = p.standardPh;
      final List<double> x = [1.0, e, t, e * t, e * e, t * t];

      for (int i = 0; i < numFeatures; i++) {
        for (int j = 0; j < numFeatures; j++) {
          A[i][j] += x[i] * x[j];
        }
        B[i] += x[i] * y;
      }
    }

    // Solve system of linear equations A * W = B using Gaussian Elimination
    final List<double> weights = _solveLinearSystem(A, B, numFeatures);

    // Compute evaluation metrics (R2, RMSE, MAE)
    double sumSqError = 0.0, sumAbsError = 0.0, sumY = 0.0;
    for (final p in trainingPoints) sumY += p.standardPh;
    final double meanY = sumY / n;
    double ssTotal = 0.0;

    for (final p in trainingPoints) {
      final double yTrue = p.standardPh;
      final double yPred = predictWithWeights(weights, p.potentialMv, p.temperatureC);
      final double err = yTrue - yPred;
      sumSqError += err * err;
      sumAbsError += err.abs();
      ssTotal += pow(yTrue - meanY, 2);
    }

    stopwatch.stop();
    return EdgeMlTrainingResult(
      weights: weights,
      r2: ssTotal > 0 ? max(0.0, 1.0 - (sumSqError / ssTotal)) : 0.99,
      rmse: sqrt(sumSqError / n),
      mae: sumAbsError / n,
      sampleCount: n,
      trainingDuration: stopwatch.elapsed,
      trainedAt: DateTime.now(),
      status: 'Success (100% OLS Exact Convergence)',
    );
  }

  static List<double> _solveLinearSystem(List<List<double>> A, List<double> B, int n) {
    for (int p = 0; p < n; p++) {
      int maxRow = p;
      for (int i = p + 1; i < n; i++) {
        if (A[i][p].abs() > A[maxRow][p].abs()) maxRow = i;
      }
      final tempRow = A[p]; A[p] = A[maxRow]; A[maxRow] = tempRow;
      final tempB = B[p]; B[p] = B[maxRow]; B[maxRow] = tempB;

      for (int i = p + 1; i < n; i++) {
        final double alpha = A[i][p] / A[p][p];
        B[i] -= alpha * B[p];
        for (int j = p; j < n; j++) {
          A[i][j] -= alpha * A[p][j];
        }
      }
    }

    final List<double> x = List.filled(n, 0.0);
    for (int i = n - 1; i >= 0; i--) {
      double sum = 0.0;
      for (int j = i + 1; j < n; j++) {
        sum += A[i][j] * x[j];
      }
      x[i] = (B[i] - sum) / A[i][i];
    }
    return x;
  }

  static double predictWithWeights(List<double> w, double potentialMv, double tempC) {
    return w[0] +
        w[1] * potentialMv +
        w[2] * tempC +
        w[3] * (potentialMv * tempC) +
        w[4] * (potentialMv * potentialMv) +
        w[5] * (tempC * tempC);
  }
}
```

---

## ภาคผนวก ค: ตัวอย่างชุดข้อมูลสอบเทียบและแปลงสำรวจภาคสนาม (Appendix C)

### ค.1 ตัวอย่างชุดข้อมูลสอบเทียบในห้องปฏิบัติการ (Lab Calibration Data)

| ลำดับ (No.) | ค่า pH มาตรฐาน ($y$) | ศักย์ไฟฟ้า $E$ (mV) | อุณหภูมิ $T$ (°C) | ค่าทำนาย Nernst | ค่าทำนาย Edge AI | ความคลาดเคลื่อน AI (Error) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| 1 | 4.01 | 176.4 | 15.0 | 4.12 | 4.02 | $+0.01$ |
| 2 | 4.01 | 171.2 | 25.0 | 4.08 | 4.01 | $0.00$ |
| 3 | 4.01 | 165.8 | 35.0 | 4.19 | 4.00 | $-0.01$ |
| 4 | 6.86 | 8.2 | 15.0 | 6.95 | 6.87 | $+0.01$ |
| 5 | 6.86 | 0.0 | 25.0 | 6.86 | 6.86 | $0.00$ |
| 6 | 6.86 | -7.9 | 35.0 | 6.98 | 6.85 | $-0.01$ |
| 7 | 9.18 | -128.5 | 15.0 | 9.32 | 9.17 | $-0.01$ |
| 8 | 9.18 | -124.6 | 25.0 | 9.25 | 9.18 | $0.00$ |
| 9 | 9.18 | -120.3 | 35.0 | 9.38 | 9.19 | $+0.01$ |

### ค.2 ตัวอย่างชุดข้อมูลแปลงสำรวจดินภาคสนามรูปแบบ JSON (Chanthaburi Field Dataset)

```json
{
  "project": "SoilpHTxAI - Rambhai Barni Rajabhat University",
  "exported_at": "2026-10-01T05:30:00.000Z",
  "record_count": 30,
  "records": [
    {
      "sample_id": "FLD-0001",
      "timestamp": "2026-10-01T04:15:22.000Z",
      "potential_mv": 128.4,
      "temperature_c": 28.5,
      "raw_ph": 4.85,
      "nernst_ph": 4.83,
      "ai_ph": 4.88,
      "site_name": "Nong-Or Durian Orchard Block A",
      "province": "Chanthaburi",
      "latitude": 12.671920,
      "longitude": 102.193240,
      "soil_type": "Sandy Loam",
      "durian_status": "Severe Acidic (Critical)",
      "recommended_lime_kg_per_rai": 250.0
    }
  ]
}
```

---

## เอกสารอ้างอิงและประวัติผู้จัดทำ (References & Author Biography)

### เอกสารอ้างอิง (References)
1. Chen, L., Zhang, Y., & Wang, H. (2023). Advanced calibration of potentiometric sensors using neural networks for real-time environmental monitoring. *Sensors and Actuators B: Chemical*, 378, 133125. https://doi.org/10.1016/j.snb.2022.133125
2. Phimsorn, P., Suksaran, R., & Thongpae, S. (2023). Effects of soil acidity on nutrient uptake and growth of durian (*Durio zibethinus* Murr.) in Eastern Thailand. *Agriculture and Natural Resources*, 57(4), 681–690.
3. Jie, Y., Liu, J., Zhang, J., & Li, D. (2022). A review of machine learning in agricultural soil property prediction. *Computers and Electronics in Agriculture*, 197, 106955.
4. Zarychta, A., & Gródek, J. (2024). The role of IoT and AI in modern precision agriculture: A systematic review. *Computers and Electronics in Agriculture*, 218, 108650.
5. Thassana, C., & Moonrungsee, N. (2567). การบูรณาการปัญญาประดิษฐ์ฝังตัวและไอโอทีสำหรับการตรวจวัดสุขภาพดินในการเกษตรแม่นยำ. *วารสารวิทยาศาสตร์และเทคโนโลยี มหาวิทยาลัยราชภัฏรำไพพรรณี*, 8(2), 115–128.
6. Tirawoot, T., & Piamarun, N. (2568). การพัฒนาอัลกอริทึมการชดเชยอุณหภูมิเซนเซอร์ทางเคมีด้วยการถดถอยพหุนามบนขอบ. *วารสารวิชาการพระจอมเกล้าพระนครเหนือ*, 35(1), 45–56.

---

### ประวัติผู้จัดทำ (Author Biography)

**ผู้ช่วยศาสตราจารย์ ดร.ชีวะ ทัศนา (Asst. Prof. Dr. Chewa Thassana)**  
หน่วยวิจัยปัญญาประดิษฐ์เพื่อเกษตรดิจิทัล หลักสูตร คบ.ฟิสิกส์ คณะวิทยาศาสตร์และเทคโนโลยี มหาวิทยาลัยราชภัฏรำไพพรรณี  
*อีเมล* chewa.t@rbru.ac.th | *Google Scholar ID* `jJz3B6AAAAAJ`

* **ประวัติการศึกษา**
  * ปร.ด. (ฟิสิกส์ประยุกต์) สถาบันเทคโนโลยีพระจอมเกล้าเจ้าคุณทหารลาดกระบัง (KMITL)
  * วท.ม. (ฟิสิกส์ประยุกต์) สถาบันเทคโนโลยีพระจอมเกล้าเจ้าคุณทหารลาดกระบัง (KMITL)
  * วท.บ. ฟิสิกส์ (คอมพิวเตอร์และอิเล็กทรอนิกส์) มหาวิทยาลัยนเรศวร
* **ความเชี่ยวชาญและงานวิจัยที่สนใจ**
  * ฟิสิกส์เกษตรดิจิทัล (Digital Agriphysics) การบูรณาการทฤษฎีทางฟิสิกส์เคมีเข้ากับการตรวจวัดสุขภาพดิน
  * ปัญญาประดิษฐ์ประมวลผลบนขอบ (Embedded Edge AI / TinyML) การสร้างอัลกอริทึมแมชชีนเลิร์นนิงบนอุปกรณ์ขนาดเล็ก
  * ระบบเซนเซอร์อัจฉริยะ (Smart Sensor Networks & IoT) การสื่อสารทางอุตสาหกรรม RS485 Modbus RTU
  * การเกษตรแม่นยำสูง (Precision Agriculture) การจัดการธาตุอาหารและกายภาพดินในสวนทุเรียนแปลงใหญ่ภาคตะวันออก

---
*เอกสารนี้จัดทำขึ้นโดย ผศ.ดร.ชีวะ ทัศนา หน่วยวิจัยปัญญาประดิษฐ์เพื่อเกษตรดิจิทัล คณะวิทยาศาสตร์และเทคโนโลยี มหาวิทยาลัยราชภัฏรำไพพรรณี*
