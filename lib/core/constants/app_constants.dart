class AppConstants {
  // Project Metadata
  static const String appName = 'SoilpHTxAI';
  static const String appSubtitle = 'AI-Compensated Soil pH & Temperature Field Analyzer';
  static const String appVersion = '1.0.0+1 (Research Edition)';

  static const String projectTitleTh =
      'การพัฒนาต้นแบบเครื่องวัดความเป็นกรด-ด่างของดินแบบพกพาภาคสนามความแม่นยำสูงด้วยการชดเชยความคลาดเคลื่อนโดยปัญญาประดิษฐ์';
  static const String projectTitleEn =
      'Development of a High-Accuracy Field-Portable Soil pH Meter Prototype with AI-based Error Compensation';
  
  static const String fundingBody = 'กองทุนวิจัย มหาวิทยาลัยราชภัฏรำไพพรรณี';
  static const String developedBy = 'ผศ.ดร.ชีวะ ทัศนา หน่วยวิจัยปัญญาประดิษฐ์เพื่อเกษตรดิจิทัล คณะวิทยาศาสตร์และเทคโนโลยี มหาวิทยาลัยราชภัฏรำไพพรรณี';
  static const String fiscalYear = 'ประจำปีงบประมาณ พ.ศ. 2569';
  static const String totalBudget = '75,000 บาท';

  // Research Team
  static const List<Map<String, String>> researchers = [
    {
      'name': 'อาจารย์ธนพัฒน์ ถิระวุฒิ',
      'role': 'หัวหน้าโครงการวิจัย (50%)',
      'dept': 'หลักสูตร คบ.ฟิสิกส์ คณะวิทยาศาสตร์และเทคโนโลยี มรภ.รำไพพรรณี',
      'responsibility': 'บริหารโครงการและรับผิดชอบหลักในการพัฒนาแบบจำลอง AI และระบบต้นแบบ',
      'email': 'tanapat.t@rbru.ac.th',
    },
    {
      'name': 'ผู้ช่วยศาสตราจารย์ ดร.ชีวะ ทัศนา',
      'role': 'ผู้ร่วมวิจัย (30%)',
      'dept': 'หลักสูตร คบ.ฟิสิกส์ คณะวิทยาศาสตร์และเทคโนโลยี มรภ.รำไพพรรณี',
      'responsibility': 'รับผิดชอบการเก็บและวิเคราะห์ข้อมูลการตอบสนองทางไฟฟ้าของเซนเซอร์เพื่อใช้สร้างโมเดล',
      'email': 'chewa.t@rbru.ac.th',
    },
    {
      'name': 'รองศาสตราจารย์ ดร.นันทพร มูลรังษี',
      'role': 'ผู้ร่วมวิจัย (10%)',
      'dept': 'สาขาวิชาเคมี คณะวิทยาศาสตร์และเทคโนโลยี มรภ.รำไพพรรณี',
      'responsibility': 'รับผิดชอบการสอบเทียบเครื่องมือและการทดสอบความถูกต้องกับตัวอย่างดิน',
      'email': 'nuntaporn.m@rbru.ac.th',
    },
    {
      'name': 'รองศาสตราจารย์ ดร.นิภัทร เปี่ยมอรุณ',
      'role': 'ผู้ร่วมวิจัย (10%)',
      'dept': 'คณะวิทยาศาสตร์และเทคโนโลยี มหาวิทยาลัยราชภัฏรำไพพรรณี',
      'responsibility': 'ผู้เชี่ยวชาญร่วมวิจัยและที่ปรึกษาด้านการประมวลผลสัญญาณและระบบอัจฉริยะ',
      'email': 'nipat.p@rbru.ac.th',
    },
  ];

  // Research Field Locations (ตามข้อเสนอโครงการ หน้า 15)
  static const List<Map<String, dynamic>> targetSites = [
    {
      'id': 'SITE-MKH-01',
      'village': 'หมู่บ้านหนองอ้อ',
      'subdistrict': 'ตำบลมะขาม',
      'district': 'อำเภอมะขาม',
      'province': 'จังหวัดจันทบุรี',
      'soilType': 'ดินร่วนปนทราย / ดินตะกอนน้ำพาริมแม่น้ำ',
      'crop': 'ทุเรียนพันธุ์หมอนทอง และกระดุมทอง',
      'lat': 12.6719,
      'lng': 102.1932,
      'typicalPh': 4.65,
    },
    {
      'id': 'SITE-THM-02',
      'village': 'บ้านหนองตาลิ่น',
      'subdistrict': 'ตำบลสองพี่น้อง',
      'district': 'อำเภอท่าใหม่',
      'province': 'จังหวัดจันทบุรี',
      'soilType': 'ดินลูกรังเขากระทิง / ดินร่วนเหนียวปนกรวด',
      'crop': 'ทุเรียนแปลงใหญ่ (หมอนทอง, ชะนี, ก้านยาว)',
      'lat': 12.6231,
      'lng': 102.0125,
      'typicalPh': 5.12,
    },
    {
      'id': 'SITE-KSM-03',
      'village': 'หมู่บ้านตาละวาย',
      'subdistrict': 'ตำบลประณีต',
      'district': 'อำเภอเขาสมิง',
      'province': 'จังหวัดตราด',
      'soilType': 'ดินกรดรุนแรงลุ่มน้ำเขาสมิง / ดินร่วนเหนียว',
      'crop': 'ทุเรียนและผลไม้เมืองร้อน (เครือข่ายมูลนิธิเก้าเกษตร)',
      'lat': 12.3551,
      'lng': 102.4418,
      'typicalPh': 4.38,
    },
  ];

  // Fundamental Physical & Electrochemical Constants
  static const double gasConstantR = 8.314462618; // J/(mol·K)
  static const double faradayConstantF = 96485.33212; // C/mol
  static const double kelvinOffset = 273.15;
  static const double naturalLog10 = 2.302585092994046; // ln(10)
  
  // Standard calibration buffers
  static const double bufferAcidic = 4.01;
  static const double bufferNeutral = 7.00;
  static const double bufferAlkaline = 10.01;
}
