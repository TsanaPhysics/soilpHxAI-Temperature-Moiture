# คู่มือการใช้งานและเอกสารอ้างอิงทางเทคนิคฉบับสมบูรณ์
## โครงการพัฒนาต้นแบบเครื่องวัดค่าความเป็นกรด-ด่างของดินภาคสนามความแม่นยำสูงด้วยการชดเชยอุณหภูมิแบบชาญฉลาดโดยใช้โครงข่ายประสาทเทียม
### (SoilpHTxAI: High-Accuracy Field-Portable Soil pH Meter Prototype with Edge AI Temperature Compensation)

---

## 1. ข้อมูลโครงการวิจัยและคณะผู้วิจัย (Research Project Information)

* **แหล่งทุนสนับสนุน:** ทุนอุดหนุนการวิจัยและนวัตกรรม มหาวิทยาลัยราชภัฏรำไพพรรณี ประจำปีงบประมาณ พ.ศ. 2569
* **หน่วยงานต้นสังกัด:** คณะวิทยาศาสตร์และเทคโนโลยี มหาวิทยาลัยราชภัฏรำไพพรรณี
* **คณะผู้วิจัย:**
  1. **อาจารย์ธนพัฒน์ ถิระวุฒิ** — หัวหน้าโครงการวิจัย (Principal Investigator)
  2. **ผู้ช่วยศาสตราจารย์ ดร.ชีวะ ทัศนา** — นักวิจัย (Co-Principal Investigator)
  3. **รองศาสตราจารย์ ดร.นันทพร มูลรังษี** — นักวิจัย (Co-Principal Investigator)
  4. **รองศาสตราจารย์ ดร.นิภัทร เปี่ยมอรุณ** — นักวิจัย (Co-Principal Investigator)
* **คลังรหัสต้นฉบับ (GitHub Repository):** [TsanaPhysics/soilpHxAI-Temperature-Moiture](https://github.com/TsanaPhysics/soilpHxAI-Temperature-Moiture.git)

---

## 2. บทนำและหลักการทางฟิสิกส์ (First-Principles Physics Foundation)

การวัดค่าความเป็นกรด-ด่าง (pH) ของดินในภาคสนามด้วยหัววัดเคมีไฟฟ้าแบบดั้งเดิมมักประสบปัญหาความคลาดเคลื่อนรุนแรงจากความผันผวนของอุณหภูมิภาคสนาม (Temperature Drift) และความไม่เป็นเชิงเส้นของโพรบ (Non-linearity) 

โครงการนี้บูรณาการสมการเนิร์นสต์ (Nernst Equation) ทางอุณหพลศาสตร์:
$$E = E_0 - S(T) \cdot (pH - 7)$$
โดยที่ความชันอุดมคติของเนิร์นสต์แปรผันตรงกับอุณหภูมิสัมบูรณ์ ($T$ ในหน่วยเคลวิน) ตามสมการ:
$$S(T) = \frac{2.3026 \cdot R \cdot T}{F}$$

ร่วมกับการใช้แบบจำลองปัญญาประดิษฐ์โครงข่ายพหุนามบนขอบ (Edge AI Polynomial Regression):
$$pH_{AI} = w_0 + w_1 E + w_2 T + w_3 (E \cdot T) + w_4 E^2 + w_5 T^2$$
ช่วยลดความคลาดเคลื่อนสะสมและชดเชยศักย์ไฟฟ้าอสมมาตร (Asymmetry Potential) ส่งผลให้การวัดมีความแม่นยำสูงเทียบเท่าเครื่องมือในห้องปฏิบัติการวิเคราะห์ (Analytical Grade)

---

## 3. สถาปัตยกรรมระบบฮาร์ดแวร์และการเชื่อมต่อ (Hardware Architecture)

```
[Soil Sensor 4-in-1] ──(RS485 Modbus RTU)──> [RS485 to USB-C Serial Module] ──(USB-C OTG)──> [Android Smartphone]
 (Moisture, Temp, EC, pH)                     (Baud Rate 9600, 8-N-1)                         (SoilpHTxAI App)
```

### 3.1 ข้อมูลจำเพาะโปรโตคอล Modbus RTU
* **Baud Rate:** 9600 bps
* **Data Bits:** 8, **Parity:** None, **Stop Bits:** 1
* **Slave Address:** `0x01`
* **Function Code:** `0x03` (Read Holding Registers)
* **Start Register:** `0x0000`, **Length:** 4 Registers (8 Bytes)
* **Request Packet (Hex):** `01 03 00 00 00 04 44 09`
* **Response Packet (13 Bytes):** `[01, 03, 08, D0, D1, D2, D3, D4, D5, D6, D7, CRC_L, CRC_H]`
  - ไบต์ที่ 3-4 (D0, D1): ค่าความชื้นสัมพัทธ์ในดิน (หาร 10.0 ได้หน่วย %)
  - ไบต์ที่ 5-6 (D2, D3): อุณหภูมิดิน (หาร 10.0 ได้หน่วย °C)
  - ไบต์ที่ 7-8 (D4, D5): ค่าการนำไฟฟ้าในดิน EC (หน่วย µS/cm)
  - ไบต์ที่ 9-10 (D6, D7): ค่า pH ดิน (หาร 100.0 ได้ค่า pH ดิน)

### 3.2 การแก้ปัญหาพอร์ตชนกันในระบบ Android (Multi-App USB Conflict Resolution)
ระบบได้รับการออกแบบเพื่อป้องกันการแย่งสิทธิ์เชื่อมต่อสาย USB-C เมื่อมีแอปพลิเคชันวัดดินหลายตัวติดตั้งอยู่ในเครื่องเดียวกัน:
1. **ปลด Intent Filter:** ลบ `android.hardware.usb.action.USB_DEVICE_ATTACHED` ออกจาก `AndroidManifest.xml` ทำให้ระบบปฏิบัติการไม่เปิดทุกแอปขึ้นมาพร้อมกันเมื่อเสียบสาย
2. **Foreground Port Claiming / Background Release:** นำ `WidgetsBindingObserver` มาใช้ควบคุมวงจรชีวิตพอร์ต เมื่อผู้ใช้สลับแอปนี้ไปอยู่เบื้องหลัง แอปจะปิดพอร์ตทันที (`disconnectUsb()`) เพื่อเปิดทางให้แอปพลิเคชันอื่นเชื่อมต่อเซนเซอร์ได้โดยไม่ต้องถอดสายออก และเมื่อสลับกลับมาเบื้องหน้า แอปจะเชื่อมต่อพอร์ตคืนโดยอัตโนมัติ (`connectUsb()`)

---

## 4. คู่มือการใช้งานโมดูลหลัก 5 หน้าจอ (User Interface Manual)

### 4.1 หน้าจอที่ 1: ตรวจวัดสดแบบเรียลไทม์ (Live Telemetry Monitor)
* **การแสดงผลค่าสด:** มาตรวัดดิจิทัลขนาดใหญ่แสดงค่า pH ชดเชยด้วย AI เทียบกับค่าสูตรเนิร์นสต์ดั้งเดิมแบบเคียงข้างกัน
* **แถบพารามิเตอร์สิ่งแวดล้อมดิน:** แสดงค่าศักย์ไฟฟ้า (mV), อุณหภูมิ (°C), ความชื้น (%), และค่าการนำไฟฟ้า EC (µS/cm)
* **แถบวิเคราะห์สุขภาพดินทุเรียน (Durian Soil Agronomic Diagnosis):** วินิจฉัยสภาพดินอัตโนมัติตามเกณฑ์เกษตรแม่นยำ (เช่น ดินเป็นกรดจัด, เหมาะสม, หรือด่าง) พร้อมคำนวณปริมาณปูนโดโลไมต์ที่ต้องใส่ปรับปรุงดิน (กก./ไร่)
* **ปุ่มควบคุมด่วนบน AppBar:**
  - 📷 **ไอคอนกล้อง:** เปิดระบบกล้อง Smart Soil Vision Camera
  - 🔌 **ไอคอน USB:** แสดงสถานะการเชื่อมต่อพอร์ต USB Serial พร้อมปุ่มกดเชื่อมต่อ/ตัดการเชื่อมต่อด้วยตนเอง
  - 📍 **ไอคอนดาวเทียม GPS:** สลับระหว่างพิกัดแปลงทดลองและพิกัดดาวเทียมจริงจากชิป GPS สมาร์ทโฟน

### 4.2 หน้าจอที่ 2: ชุดข้อมูลสอบเทียบและฝึกฝนโมเดลบนเครื่อง (Laboratory Dataset & Edge ML)
* **การจำแนกข้อมูลตามสัดส่วน:** แบ่งชุดข้อมูลมาตรฐาน (pH 4.01, 7.00, 10.01 ณ อุณหภูมิ 20-50°C) ออกเป็น Train (70%), Validation (15%), และ Test (15%)
* **🧠 ระบบฝึกฝนโมเดล AI บนเครื่อง (Pure Dart Edge ML Trainer):**
  - กดปุ่มเพื่อเปิดหน้าต่าง Edge ML Trainer
  - กดปุ่ม **"เริ่มฝึกฝนโมเดลใหม่ (Train Model On-Device)"** เพื่อให้ระบบคำนวณ OLS Normal Equation ฟิตสัมประสิทธิ์พหุนามสดบน CPU ของมือถือ
  - แสดงค่าสถิติ $R^2$, RMSE, MAE, เวลาที่ใช้ในการประมวลผล (มิลลิวินาที) และค่าน้ำหนักสัมประสิทธิ์ ($w_0$ ถึง $w_5$)
  - กด **"นำไปใช้งานทันที"** เพื่ออัปเดตโมเดลเข้าสู่ระบบตรวจวัดสด (Hot-Swapping) หรือกด **"รีเซ็ตสู่ค่าเริ่มต้น"** เพื่อคืนสู่ค่ามาตรฐาน RBRU Baseline 2569
* **☁️ การส่งออกข้อมูล Cloud / Google Drive:**
  - กดไอคอน Cloud บน AppBar เพื่อส่งออกชุดข้อมูลสอบเทียบทั้งหมดในรูปแบบไฟล์ `.csv` เข้าสู่ Google Drive, Gmail หรือแอปอื่น ๆ ได้ทันที

### 4.3 หน้าจอที่ 3: การทดสอบสมมติฐานทางสถิติ (Hypothesis Testing Screen)
* **การทดสอบสมมติฐานการวิจัย (Proposal Step 5.2):**
  - สมมติฐานว่าง ($H_0$): $RMSE_{AI} \ge RMSE_{traditional}$
  - สมมติฐานทางเลือก ($H_1$): $RMSE_{AI} < RMSE_{traditional}$
* **ผลการวิเคราะห์สถิติอนุมาน (Paired t-test):** แสดงค่า $t$-statistic, ค่า $p$-value ($p < 0.001$), เปอร์เซ็นต์การลดทอนความคลาดเคลื่อน (% Error Reduction) และแถบเปรียบเทียบ RMSE/MAE ชัดเจน

### 4.4 หน้าจอที่ 4: การสำรวจดินภาคสนามและการจัดการปูน (Field Survey Screen)
* **คลังข้อมูลดินแปลงปลูกจริง:** บันทึกตัวอย่างดิน 30 แปลงในเขตจังหวัดจันทบุรีและตราด (ขลุง, ท่าใหม่, มะขาม, เขาคิชฌกูฏ, เขาสมิง, บ่อไร่)
* **ระบบบันทึกตัวอย่างดินใหม่:** ดึงค่าเซนเซอร์สดพร้อมพิกัด GPS จริงมาบันทึกเป็นตัวอย่างดินใหม่ได้ทันที
* **การแชร์ข้อมูลสำรวจ:** ส่งออกข้อมูลแปลงดินพร้อมคำแนะนำปริมาณปูนโดโลไมต์ในรูปแบบ `.csv` หรือ `.json`

### 4.5 หน้าจอที่ 5: ข้อมูลโครงการวิจัยและเฟิร์มแวร์ ESP32 (Project & Firmware Screen)
* แสดงรายละเอียดทุนวิจัยและรายนามคณะผู้วิจัยทั้ง 4 ท่าน
* **เครื่องมือสร้างซอร์สโค้ดภาษา C++ สำหรับไมโครคอนโทรลเลอร์ (C++ Arduino Generator):** นำค่าน้ำหนัก AI ล่าสุดมาเจนโค้ด C++ พร้อมฟังก์ชัน `predictAiCompensatedPh` สำหรับนำไปแฟลชลงบอร์ด ESP32 ได้ทันที

---

## 5. ระบบกล้องสมาร์ทวิชันตรวจวิเคราะห์หน้าดิน (Smart Soil Vision Camera)

พัฒนาเพื่อบันทึกภาพถ่ายตัวอย่างดินพร้อมบริบทเชิงวิศวกรรม:
1. **Live Telemetry HUD:** แสดงค่า pH AI, ศักย์ไฟฟ้า (mV), อุณหภูมิ (°C), และความชื้น (%) ลอยอยู่บนภาพกล้องแบบเรียลไทม์
2. **GPS Geotag Overlay:** แสดงพิกัดละติจูดและลองจิจูดจากชิปดาวเทียมกำกับบนหน้าจอ
3. **Soil Focus Reticle:** แสดงกรอบเล็งเป้ากึ่งกลางจอเพื่อจัดวางโพรบหรือตัวอย่างดิน
4. **Hardware Torch & Camera Switcher:** สลับกล้องหน้า-หลัง และเปิดไฟฉายช่วยส่องสว่างหน้าดินในที่มืด
5. **Image & Metadata Capture:** บันทึกภาพถ่ายตัวอย่างดินความละเอียดสูงพร้อมกล่องยืนยันข้อมูลตัวอย่างดิน (Sample ID, พิกัด, ค่าที่อ่านได้)

---

## 6. แนวทางการติดตั้ง ซอร์สโค้ด และคอมไพล์ (Setup, Build & Deployment)

### 6.1 ความต้องการของระบบ (Prerequisites)
* Flutter SDK Version $\ge$ 3.11.5 (หรือ SDK 3.38+)
* Android SDK Platform API 33+ (Android 13+)
* อุปกรณ์สมาร์ทโฟนที่รองรับพอร์ต USB-C OTG

### 6.2 การตรวจสอบคุณภาพซอร์สโค้ด (Quality Assurance)
```bash
# ตรวจสอบรูปแบบและข้อผิดพลาดของซอร์สโค้ด (Static Analysis)
flutter analyze

# รันการทดสอบ Unit Tests และ Zero RenderFlex Overflow Tests (20 การทดสอบ)
flutter test
```

### 6.3 การคอมไพล์และติดตั้งลงเครื่องสมาร์ทโฟน (Build & Install)
```bash
# คอมไพล์ไฟล์ APK สำหรับทดสอบ
flutter build apk --debug

# ติดตั้งลงในสมาร์ทโฟนผ่าน ADB (สาย USB Debugging)
adb -s <DEVICE_SERIAL_ID> install -r build/app/outputs/flutter-apk/app-debug.apk

# เปิดแอปพลิเคชัน
adb -s <DEVICE_SERIAL_ID> shell monkey -p com.rbru.soilphtxai.soil_pht_x_ai -c android.intent.category.LAUNCHER 1
```

---

## 7. รหัสต้นแบบเฟิร์มแวร์ C++ สำหรับ ESP32 / Arduino (Embedded Firmware Code)

```cpp
// ============================================================================
// SoilpHTxAI - Embedded AI Error Compensation Engine for ESP32 / Arduino
// Project: Development of a High-Accuracy Field-Portable Soil pH Meter Prototype
// Funding: Rambhai Barni Rajabhat University Research Fund 2569
// Principal Investigators: 
//   Tanapat Tirawoot, Asst.Prof.Dr. Chewa Thassana, 
//   Assoc.Prof.Dr. Nuntaporn Moonrungsee, Assoc.Prof.Dr. Nipat Piamarun
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
  // Read analog potential from pH probe (GPIO 34) and Temperature (DS18B20)
  float rawMv = 118.5f; // Replace with analogReadMilliVolts(34)
  float tempC = 28.5f;  // Replace with sensors.getTempCByIndex(0)
  
  float phAI = predictAiCompensatedPh(rawMv, tempC);
  
  Serial.print("{\"potential_mv\":");
  Serial.print(rawMv);
  Serial.print(",\"temperature_c\":");
  Serial.print(tempC);
  Serial.print(",\"ai_ph\":");
  Serial.print(phAI, 2);
  Serial.println("}");
  
  delay(1000);
}
```

---
*เอกสารนี้จัดทำขึ้นโดยทีมวิจัยและพัฒนาวิศวกรรมซอฟต์แวร์ มหาวิทยาลัยราชภัฏรำไพพรรณี ประจำปีงบประมาณ 2569*
