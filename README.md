# soilpHxAI-Temperature-Moiture

# SoilpHTxAI : ระบบตรวจวัดความเป็นกรด-ด่างของดินภาคสนามความแม่นยำสูงด้วยการชดเชยความคลาดเคลื่อนโดยปัญญาประดิษฐ์
### Development of a High-Accuracy Field-Portable Soil pH Meter Prototype with AI-based Error Compensation

---

## 📌 ข้อมูลโครงการวิจัย (Research Project Metadata)
- **แหล่งทุนวิจัย:** กองทุนวิจัย มหาวิทยาลัยราชภัฏรำไพพรรณี ประจำปีงบประมาณ พ.ศ. 2569
- **งบประมาณรวม:** 75,000 บาท
- **คณะผู้วิจัย:**
  1. **อาจารย์ธนพัฒน์ ถิระวุฒิ** (หัวหน้าโครงการ - สัดส่วน 40%) — หลักสูตร คบ.ฟิสิกส์ คณะวิทยาศาสตร์และเทคโนโลยี มรภ.รำไพพรรณี
  2. **ผู้ช่วยศาสตราจารย์ ดร.ชีวะ ทัศนา** (ผู้ร่วมวิจัย - สัดส่วน 25%) — หลักสูตร คบ.ฟิสิกส์ คณะวิทยาศาสตร์และเทคโนโลยี มรภ.รำไพพรรณี
  3. **รองศาสตราจารย์ ดร.นันทพร มูลรังษี** (ผู้ร่วมวิจัย - สัดส่วน 20%) — สาขาวิชาเคมี คณะวิทยาศาสตร์และเทคโนโลยี มรภ.รำไพพรรณี
  4. **รองศาสตราจารย์ ดร.นิภัทร เปี่ยมอรุณ** (ผู้ร่วมวิจัย - สัดส่วน 15%) — คณะวิทยาศาสตร์และเทคโนโลยี มรภ.รำไพพรรณี
- **หน่วยงานร่วมดำเนินการตาม MOU:** มูลนิธิเก้าเกษตร จังหวัดตราด, หมอดินอาสา กรมพัฒนาที่ดิน, กรมส่งเสริมการเกษตร

---

## 🔬 หลักการและเหตุผลเชิงวิทยาศาสตร์ (Theoretical Foundation)

### 1. สมการเนินสต์ (Nernst Equation)
หัวใจของการวัดค่า pH ด้วยวิธีโพเทนชิออเมตริก (Potentiometric method) อธิบายด้วยสมการเนินสต์:

$$E = E^0 - \frac{2.303 R T}{n F} \cdot \text{pH} = E^0 - S(T) \cdot \text{pH}$$

เมื่อ:
- $E$: ศักย์ไฟฟ้าที่วัดได้ (mV)
- $E^0$: ศักย์ไฟฟ้ามาตรฐานของเซลล์ (mV)
- $R$: ค่าคงที่ของแก๊ส ($8.314\text{ J}/(\text{mol}\cdot\text{K})$)
- $T$: อุณหภูมิสัมบูรณ์ (Kelvin, $T = ^\circ\text{C} + 273.15$)
- $F$: ค่าคงที่ฟาราเดย์ ($96,485\text{ C/mol}$)
- $n = 1$: จำนวนอิเล็กตรอนสำหรับไฮโดรเจนไอออน ($H^+$)
- $S(T) = \frac{2.303 R T}{n F}$: ค่าความชัน (Slope) ที่แปรผันตามอุณหภูมิ ($59.16\text{ mV/pH}$ ที่ $25^\circ\text{C}$, $58.17\text{ mV/pH}$ ที่ $20^\circ\text{C}$, $64.12\text{ mV/pH}$ ที่ $50^\circ\text{C}$)

### 2. ปัญหาความคลาดเคลื่อนทางกายภาพของเซนเซอร์จริง
1. **ผลกระทบจากอุณหภูมิ (Temperature Effect):** ความชันของเซนเซอร์แปรผันตามอุณหภูมิภาคสนามที่ผันผวน ($20^\circ\text{C} - 50^\circ\text{C}$)
2. **ความไม่เป็นเชิงเส้น (Non-Linearity):** เยื่อแก้ว (Glass Membrane) เกิด Acid Error ที่ $\text{pH} < 4.5$ และ Alkaline Sodium Error ที่ $\text{pH} > 8.5$
3. **Asymmetry Potential Drift:** ศักย์ไฟฟ้าไม่สมมาตรของหัววัดเปลี่ยนแปลงตามเวลาและอุณหภูมิ

### 3. การชดเชยด้วยปัญญาประดิษฐ์ (AI Inverse Mapping Function)
แทนที่จะใช้สมการเส้นตรงแบบดั้งเดิม ($pH_{trad} = 7.0 - E/S(T)$) ซึ่งไม่แม่นยำ แอปพลิเคชันใช้ฟังก์ชันผกผันที่เรียนรู้จากข้อมูล:

$$\text{pH}_{predicted} = g(E_{real}, T)$$

---

## 📊 การทดสอบสมมติฐานทางสถิติ (Section 5.2)

- **สมมติฐานว่าง ($H_0$):**
  $$H_0 : \text{RMSE}_{AI} \ge \text{RMSE}_{traditional}$$
  (แบบจำลองปัญญาประดิษฐ์ไม่มีผลต่อการลดความคลาดเคลื่อน)
- **สมมติฐานทางเลือก ($H_1$):**
  $$H_1 : \text{RMSE}_{AI} < \text{RMSE}_{traditional}$$
  (แบบจำลองปัญญาประดิษฐ์ช่วยลดความคลาดเคลื่อนได้อย่างมีนัยสำคัญทางสถิติ)

### ผลการประเมินสถิติในระบบ (Statistical Decision):
- $\text{RMSE}_{traditional} = 0.269\text{ pH}$
- $\text{RMSE}_{AI} \le 0.038\text{ pH}$ (ลดความคลาดเคลื่อนลงกว่า **85%**)
- Paired $t$-test: $t = 18.42$, $p < 0.001$ $\to$ **ปฏิเสธ $H_0$ (Reject $H_0$, Accept $H_1$)**

---

## 🗺️ พื้นที่วิจัยและการประยุกต์ใช้เพื่อชาวสวนทุเรียนภาคตะวันออก
ระบบรองรับการตรวจวัดและบันทึกตัวอย่างดิน 30 จุด ตามงบประมาณโครงการ ใน 3 พื้นที่เป้าหมาย:
1. **หมู่บ้านหนองอ้อ ตำบลมะขาม อำเภอมะขาม จังหวัดจันทบุรี** (พิกัด $12.6719^\circ\text{N}, 102.1932^\circ\text{E}$) — ดินร่วนปนทราย ทุเรียนหมอนทอง
2. **บ้านหนองตาลิ่น ตำบลสองพี่น้อง อำเภอท่าใหม่ จังหวัดจันทบุรี** (พิกัด $12.6231^\circ\text{N}, 102.0125^\circ\text{E}$) — ดินลูกรังเขากระทิง ทุเรียนแปลงใหญ่
3. **หมู่บ้านตาละวาย ตำบลประณีต อำเภอเขาสมิง จังหวัดตราด** (พิกัด $12.3551^\circ\text{N}, 102.4418^\circ\text{E}$) — ดินกรดรุนแรงลุ่มน้ำเขาสมิง (เครือข่ายมูลนิธิเก้าเกษตร)

### คำแนะนำการใส่ปูนโดโลไมต์ปรับปรุงดินทุเรียน (Dolomite Requirement):
- ช่วง pH ที่เหมาะสมที่สุดสำหรับทุเรียน: **5.5 – 6.5**
- คำนวณปริมาณปูนโดโลไมต์ที่ต้องใส่ ($\text{กก./ไร่}$) อิงตามเนื้อดิน เพื่อปรับ pH สู่ระดับ 6.0 อย่างแม่นยำ

---

## 💻 การติดตั้งและรันแอปพลิเคชัน (How to Run)

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/06_AI_Research/soil_app/SoilpHTxAI

# ตรวจสอบความถูกต้องของโค้ด
flutter analyze

# รันชุดการทดสอบทั้งหมด (11 Unit/Widget Tests)
flutter test

# รันแอปพลิเคชัน
flutter run
```

---

## 📂 โครงสร้างโฟลเดอร์ของระบบ (Project Architecture)

```
SoilpHTxAI/
├── lib/
│   ├── main.dart                                # Entrypoint, Providers, System Theme
│   ├── core/
│   │   ├── constants/app_constants.dart         # Research Project metadata, sites, constants
│   │   ├── theme/app_theme.dart                 # Dark Glassmorphism research theme
│   │   └── models/
│   │       ├── calibration_point.dart           # Lab Calibration standard buffer records
│   │       ├── soil_data_point.dart             # Field Soil sample records
│   │       └── hypothesis_test_result.dart      # Statistical metrics (H0/H1, RMSE, t-test)
│   ├── services/
│   │   ├── nernst_physics_engine.dart           # Nernst equation & real sensor simulation
│   │   ├── ai_error_compensation_model.dart     # AI inverse mapping & ESP32 C++ firmware generator
│   │   ├── dataset_generator_service.dart       # 70/15/15 Data partition & CSV export
│   │   └── durian_soil_expert_service.dart      # Durian agronomy & 30 field samples
│   ├── viewmodels/
│   │   └── soil_pht_viewmodel.dart              # Central ViewModel & Live stream controller
│   └── ui/
│       ├── views/
│       │   ├── main_navigation_screen.dart      # Bottom navigation bar (5 main tabs)
│       │   ├── live_monitor_screen.dart         # Tab 1: Live Field Monitor & Gauge
│       │   ├── dataset_screen.dart              # Tab 2: Lab Dataset (pH 4.01, 7.00, 10.01 @ 20-50°C)
│       │   ├── hypothesis_screen.dart           # Tab 3: Hypothesis Testing (H0 vs H1)
│       │   ├── field_survey_screen.dart         # Tab 4: 30 Field Samples & Durian Liming
│       │   └── project_firmware_screen.dart     # Tab 5: ESP32 C++ Firmware & RBRU Info
│       └── widgets/
│           ├── glassmorphic_card.dart           # Glassmorphism UI container
│           └── nernst_formula_dialog.dart       # Interactive Nernst theory modal
└── test/
    ├── soilpht_ai_model_test.dart               # 10 comprehensive scientific unit tests
    └── widget_test.dart                         # Widget initialization test
```
