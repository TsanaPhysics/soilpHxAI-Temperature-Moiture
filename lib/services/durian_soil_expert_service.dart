import '../core/models/soil_data_point.dart';
import 'ai_error_compensation_model.dart';
import 'nernst_physics_engine.dart';

class DurianSoilExpertService {
  /// Diagnose soil suitability for Durian cultivation based on Phimsorn et al. (2023)
  static Map<String, dynamic> diagnoseSoilStatus(double ph) {
    if (ph < 4.5) {
      return {
        'status': 'ดินกรดรุนแรงมาก (Strongly Acidic)',
        'color': 0xFFEF4444, // Red
        'isOptimal': false,
        'description':
            'ระดับ pH ต่ำมาก เกิดภาวะเป็นพิษของอะลูมิเนียม (Al) และแมงกานีส (Mn) ขัดขวางการงอกและดูดซึมธาตุอาหารของรากทุเรียน เสี่ยงต่อเชื้อรา Phytophthora รากเน่าโคนเน่าสูงมาก',
        'action': 'ต้องปรับปรุงดินด้วยปูนโดโลไมต์ทันที และงดการใส่ปุ๋ยเคมีไนโตรเจนรูปแอมโมเนียมชั่วคราว',
      };
    } else if (ph < 5.5) {
      return {
        'status': 'ดินเป็นกรดปานกลาง (Moderately Acidic)',
        'color': 0xFFF59E0B, // Amber
        'isOptimal': false,
        'description':
            'ฟอสฟอรัส (P), โพแทสเซียม (K), แคลเซียม (Ca) และแมกนีเซียม (Mg) เริ่มถูกตรึงในดิน ประสิทธิภาพการดูดซึมปุ๋ยของทุเรียนลดลง 25-40%',
        'action': 'ใส่ปูนโดโลไมต์ปรับสภาพดินช่วงต้นฤดูฝน หว่านรอบทรงพุ่มเพื่อยกระดับ pH สู่ช่วง 6.0',
      };
    } else if (ph <= 6.5) {
      return {
        'status': 'ช่วงที่เหมาะสมที่สุดสำหรับทุเรียน (Optimal Range)',
        'color': 0xFF10B981, // Emerald
        'isOptimal': true,
        'description':
            'ค่าความเป็นกรด-ด่างสมบูรณ์แบบ ธาตุอาหารหลัก N-P-K และธาตุอาหารรอง Ca-Mg-S ละลายได้สูงสุด รากฝอยทุเรียนแผ่กระจายตัวและแข็งแรงดีเยี่ยม',
        'action': 'รักษาอินทรียวัตถุในดินด้วยปุ๋ยหมักชีวภาพ และตรวจติดตามค่า pH สม่ำเสมอ',
      };
    } else if (ph <= 7.5) {
      return {
        'status': 'ดินเป็นกลางถึงด่างเล็กน้อย (Neutral to Slightly Alkaline)',
        'color': 0xFF06B6D4, // Cyan
        'isOptimal': false,
        'description':
            'การดูดซึมฟอสฟอรัสและไนโตรเจนยังอยู่ในเกณฑ์ดี แต่ควรระวังการขาดจุลธาตุเช่น สังกะสี (Zn) และเหล็ก (Fe)',
        'action': 'งดการใช้ปูนขาวหรือโดโลไมต์ ให้ใช้ปุ๋ยเคมีที่มีความเป็นกรดอ่อนเพื่อปรับสมดุล',
      };
    } else {
      return {
        'status': 'ดินเป็นด่างสูง (Alkaline Soil)',
        'color': 0xFF8B5CF6, // Purple
        'isOptimal': false,
        'description':
            'ทุเรียนจะแสดงอาการใบเหลืองยอดแห้งเนื่องจากการขาดธาตุเหล็ก (Fe), แมงกานีส (Mn) และสังกะสี (Zn) อย่างรุนแรง',
        'action': 'ใส่กำมะถันผงหรือยิปซัมเพื่อลดความเป็นด่าง และพ่นจุลธาตุคีเลตทางใบเสริม',
      };
    }
  }

  /// Calculate recommended dolomite lime application rate (kg/rai)
  /// Target pH = 6.0
  static double calculateRecommendedLimeKgPerRai({
    required double currentPh,
    required String soilType,
  }) {
    if (currentPh >= 6.0) return 0.0;
    final double deltaPh = 6.0 - currentPh;

    double bufferingFactor = 250.0; // kg dolomite per 1.0 pH unit increase in sandy loam
    if (soilType.contains('เหนียว') || soilType.contains('ลูกรัง')) {
      bufferingFactor = 380.0;
    } else if (soilType.contains('กรดรุนแรง')) {
      bufferingFactor = 450.0;
    }

    final double limeRate = deltaPh * bufferingFactor;
    return double.parse(limeRate.toStringAsFixed(1));
  }

  /// Generate the 30 field soil samples budgeted in the proposal (Page 16 & 19):
  /// 30 samples analyzed by standard lab benchtop pH meter (30 x 250 = 7,500 THB)
  static List<SoilDataPoint> getResearchFieldSamples() {
    final List<SoilDataPoint> samples = [];

    // 10 samples from Nong O, Makham, Chanthaburi
    final List<double> mkhPhs = [4.45, 4.60, 4.75, 4.52, 4.68, 4.80, 4.35, 4.58, 4.72, 4.62];
    for (int i = 0; i < 10; i++) {
      final double labPh = mkhPhs[i];
      final double tempC = 28.5 + (i * 0.4);
      final double potentialMv = NernstPhysicsEngine.simulateRealSensorPotential(
        truePh: labPh,
        temperatureC: tempC,
        includeNonLinearity: true,
        includeNoise: false,
      );
      final double nernstPh = NernstPhysicsEngine.calculateNernstPh(
        potentialMv: potentialMv,
        temperatureC: tempC,
      );
      final double aiPh = AiErrorCompensationModel.predict(
        potentialMv: potentialMv,
        temperatureC: tempC,
      );
      final diag = diagnoseSoilStatus(aiPh);

      samples.add(
        SoilDataPoint(
          sampleId: 'SMP-MKH-${(i + 1).toString().padLeft(2, '0')}',
          timestamp: DateTime.now().subtract(Duration(days: 15 - i)),
          potentialMv: potentialMv,
          temperatureC: tempC,
          rawPh: double.parse((7.0 - potentialMv / 59.16).toStringAsFixed(2)),
          nernstPh: nernstPh,
          aiPh: aiPh,
          labStandardPh: labPh,
          siteName: 'หมู่บ้านหนองอ้อ ตำบลมะขาม',
          province: 'จังหวัดจันทบุรี',
          latitude: 12.6719 + (i * 0.0012),
          longitude: 102.1932 + (i * 0.0008),
          soilType: 'ดินร่วนปนทราย',
          durianStatus: diag['status'],
          recommendedLimeKgPerRai: calculateRecommendedLimeKgPerRai(
            currentPh: aiPh,
            soilType: 'ดินร่วนปนทราย',
          ),
        ),
      );
    }

    // 10 samples from Nong Ta Lin, Song Phi Nong, Tha Mai, Chanthaburi
    final List<double> thmPhs = [5.10, 5.25, 4.95, 5.30, 5.05, 5.18, 5.40, 4.88, 5.15, 5.22];
    for (int i = 0; i < 10; i++) {
      final double labPh = thmPhs[i];
      final double tempC = 31.0 + (i * 0.3);
      final double potentialMv = NernstPhysicsEngine.simulateRealSensorPotential(
        truePh: labPh,
        temperatureC: tempC,
        includeNonLinearity: true,
        includeNoise: false,
      );
      final double nernstPh = NernstPhysicsEngine.calculateNernstPh(
        potentialMv: potentialMv,
        temperatureC: tempC,
      );
      final double aiPh = AiErrorCompensationModel.predict(
        potentialMv: potentialMv,
        temperatureC: tempC,
      );
      final diag = diagnoseSoilStatus(aiPh);

      samples.add(
        SoilDataPoint(
          sampleId: 'SMP-THM-${(i + 1).toString().padLeft(2, '0')}',
          timestamp: DateTime.now().subtract(Duration(days: 12 - i)),
          potentialMv: potentialMv,
          temperatureC: tempC,
          rawPh: double.parse((7.0 - potentialMv / 59.16).toStringAsFixed(2)),
          nernstPh: nernstPh,
          aiPh: aiPh,
          labStandardPh: labPh,
          siteName: 'บ้านหนองตาลิ่น ตำบลสองพี่น้อง',
          province: 'จังหวัดจันทบุรี',
          latitude: 12.6231 + (i * 0.0009),
          longitude: 102.0125 + (i * 0.0011),
          soilType: 'ดินลูกรังเขากระทิง / ร่วนเหนียว',
          durianStatus: diag['status'],
          recommendedLimeKgPerRai: calculateRecommendedLimeKgPerRai(
            currentPh: aiPh,
            soilType: 'ดินลูกรังเขากระทิง / ร่วนเหนียว',
          ),
        ),
      );
    }

    // 10 samples from Ta La Wai, Khao Saming, Trat (MOU Kao Kaset Foundation)
    final List<double> ksmPhs = [4.20, 4.35, 4.15, 4.40, 4.28, 4.50, 4.10, 4.32, 4.45, 4.25];
    for (int i = 0; i < 10; i++) {
      final double labPh = ksmPhs[i];
      final double tempC = 33.2 + (i * 0.25);
      final double potentialMv = NernstPhysicsEngine.simulateRealSensorPotential(
        truePh: labPh,
        temperatureC: tempC,
        includeNonLinearity: true,
        includeNoise: false,
      );
      final double nernstPh = NernstPhysicsEngine.calculateNernstPh(
        potentialMv: potentialMv,
        temperatureC: tempC,
      );
      final double aiPh = AiErrorCompensationModel.predict(
        potentialMv: potentialMv,
        temperatureC: tempC,
      );
      final diag = diagnoseSoilStatus(aiPh);

      samples.add(
        SoilDataPoint(
          sampleId: 'SMP-KSM-${(i + 1).toString().padLeft(2, '0')}',
          timestamp: DateTime.now().subtract(Duration(days: 8 - i)),
          potentialMv: potentialMv,
          temperatureC: tempC,
          rawPh: double.parse((7.0 - potentialMv / 59.16).toStringAsFixed(2)),
          nernstPh: nernstPh,
          aiPh: aiPh,
          labStandardPh: labPh,
          siteName: 'หมู่บ้านตาละวาย ตำบลประณีต',
          province: 'จังหวัดตราด',
          latitude: 12.3551 + (i * 0.0010),
          longitude: 102.4418 + (i * 0.0007),
          soilType: 'ดินกรดรุนแรงลุ่มน้ำเขาสมิง',
          durianStatus: diag['status'],
          recommendedLimeKgPerRai: calculateRecommendedLimeKgPerRai(
            currentPh: aiPh,
            soilType: 'ดินกรดรุนแรงลุ่มน้ำเขาสมิง',
          ),
        ),
      );
    }

    return samples;
  }
}
