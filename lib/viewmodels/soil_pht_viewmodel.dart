import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../core/models/calibration_point.dart';
import '../core/models/soil_data_point.dart';
import '../core/models/hypothesis_test_result.dart';
import '../core/models/ph_sensor_reading.dart';
import '../services/nernst_physics_engine.dart';
import '../services/ai_error_compensation_model.dart';
import '../services/dataset_generator_service.dart';
import '../services/durian_soil_expert_service.dart';
import '../services/usb_soil_sensor_service.dart';
import '../core/constants/app_constants.dart';

class SoilPhtViewModel extends ChangeNotifier {
  // Real-time sensor state
  double _potentialMv = 118.5; // Defaults around pH 5.0
  double _temperatureC = 30.0;
  bool _isStreaming = true;
  bool _isAiCompensationEnabled = true;
  Timer? _streamTimer;

  // Physical USB-C Soil Parameter Sensor Service
  late final UsbSoilSensorService _usbService;
  StreamSubscription<SoilPhReading>? _usbReadingSub;
  StreamSubscription<UsbStatus>? _usbStatusSub;
  UsbStatus _usbStatus = UsbStatus.disconnected;
  double _usbMoisture = 48.5;
  int _usbEc = 450;
  double _usbRawPh = 5.20;

  // Calibration dataset and hypothesis results
  List<CalibrationPoint> _calibrationDataset = [];
  HypothesisTestResult? _hypothesisResult;

  // Field samples
  List<SoilDataPoint> _fieldSamples = [];
  int _selectedSiteIndex = 0;

  // Selected soil simulation target (used when USB is not connected)
  double _targetGroundTruthPh = 5.20;

  SoilPhtViewModel() {
    _usbService = UsbSoilSensorService();
    _initUsbListeners();
    _initializeData();
    _startLiveStream();
  }

  void _initUsbListeners() {
    _usbStatus = _usbService.status;
    _usbStatusSub = _usbService.statusStream.listen((status) {
      _usbStatus = status;
      notifyListeners();
    });

    _usbReadingSub = _usbService.readingStream.listen((reading) {
      _usbMoisture = reading.moisture;
      _usbEc = reading.conductivity;
      _usbRawPh = reading.phRaw;
      _temperatureC = reading.temperature;
      _potentialMv = reading.sensorVoltageMv;
      _targetGroundTruthPh = reading.phRaw;
      notifyListeners();
    });
  }

  // Getters
  double get potentialMv => _potentialMv;
  double get temperatureC => _temperatureC;
  bool get isStreaming => _isStreaming;
  bool get isAiCompensationEnabled => _isAiCompensationEnabled;
  double get targetGroundTruthPh => _targetGroundTruthPh;

  // USB Status & Parameters
  UsbStatus get usbStatus => _usbStatus;
  bool get isUsbConnected => _usbStatus == UsbStatus.connected;
  double get usbMoisture => _usbMoisture;
  int get usbEc => _usbEc;
  double get usbRawPh => _usbRawPh;
  int get usbBaudRate => _usbService.currentBaudRate;
  String get usbLastHexRx => _usbService.lastHexRx;
  String get usbLastHexTx => _usbService.lastHexTx;

  double get currentNernstSlope =>
      NernstPhysicsEngine.calculateNernstSlopeMv(_temperatureC);

  double get currentRawPh {
    if (isUsbConnected) {
      return _usbRawPh;
    }
    // Uncalibrated linear assumption (fixed 59.16 mV slope without temp compensation)
    return double.parse((7.0 - (_potentialMv / 59.16)).clamp(0.0, 14.0).toStringAsFixed(2));
  }

  double get currentNernstPh {
    return NernstPhysicsEngine.calculateNernstPh(
      potentialMv: _potentialMv,
      temperatureC: _temperatureC,
    );
  }

  double get currentAiPh {
    return AiErrorCompensationModel.predict(
      potentialMv: _potentialMv,
      temperatureC: _temperatureC,
    );
  }

  double get displayedPh =>
      _isAiCompensationEnabled ? currentAiPh : currentNernstPh;

  Map<String, dynamic> get currentDurianDiagnosis =>
      DurianSoilExpertService.diagnoseSoilStatus(displayedPh);

  List<CalibrationPoint> get calibrationDataset => _calibrationDataset;
  HypothesisTestResult? get hypothesisResult => _hypothesisResult;
  List<SoilDataPoint> get fieldSamples => _fieldSamples;
  int get selectedSiteIndex => _selectedSiteIndex;
  Map<String, dynamic> get currentTargetSite =>
      AppConstants.targetSites[_selectedSiteIndex];

  void _initializeData() {
    _calibrationDataset = DatasetGeneratorService.generateFullResearchDataset();
    _hypothesisResult = DatasetGeneratorService.evaluateHypothesis(_calibrationDataset);
    _fieldSamples = DurianSoilExpertService.getResearchFieldSamples();
  }

  void _startLiveStream() {
    _streamTimer?.cancel();
    _streamTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!_isStreaming) return;
      // If USB is actively connected, readings are updated directly via USB stream
      if (isUsbConnected) return;
      _updateSimulatedReading();
    });
  }

  void _updateSimulatedReading() {
    final Random rng = Random();
    // Slight thermal fluctuation (±0.4 °C)
    final double tempJitter = (rng.nextDouble() - 0.5) * 0.4;
    _temperatureC = double.parse((_temperatureC + tempJitter).clamp(18.0, 48.0).toStringAsFixed(1));

    // Realistic sensor potential with non-linear drift and noise
    _potentialMv = NernstPhysicsEngine.simulateRealSensorPotential(
      truePh: _targetGroundTruthPh,
      temperatureC: _temperatureC,
      includeNonLinearity: true,
      includeNoise: true,
    );

    notifyListeners();
  }

  void toggleStreaming() {
    _isStreaming = !_isStreaming;
    notifyListeners();
  }

  void toggleAiCompensation() {
    _isAiCompensationEnabled = !_isAiCompensationEnabled;
    notifyListeners();
  }

  void setTargetGroundTruthPh(double ph) {
    _targetGroundTruthPh = double.parse(ph.clamp(2.0, 12.0).toStringAsFixed(2));
    if (!isUsbConnected) {
      _potentialMv = NernstPhysicsEngine.simulateRealSensorPotential(
        truePh: _targetGroundTruthPh,
        temperatureC: _temperatureC,
        includeNonLinearity: true,
        includeNoise: false,
      );
    }
    notifyListeners();
  }

  void setTemperature(double temp) {
    _temperatureC = double.parse(temp.clamp(15.0, 55.0).toStringAsFixed(1));
    if (!isUsbConnected) {
      _potentialMv = NernstPhysicsEngine.simulateRealSensorPotential(
        truePh: _targetGroundTruthPh,
        temperatureC: _temperatureC,
        includeNonLinearity: true,
        includeNoise: false,
      );
    }
    notifyListeners();
  }

  Future<void> connectUsb() async {
    await _usbService.autoConnect();
    notifyListeners();
  }

  Future<void> disconnectUsb() async {
    await _usbService.disconnect();
    notifyListeners();
  }

  void selectTargetSite(int index) {
    if (index >= 0 && index < AppConstants.targetSites.length) {
      _selectedSiteIndex = index;
      final site = AppConstants.targetSites[index];
      setTargetGroundTruthPh(site['typicalPh'] as double);
      notifyListeners();
    }
  }

  void logCurrentFieldSample() {
    final site = currentTargetSite;
    final String sampleId =
        'SMP-NEW-${(_fieldSamples.length + 1).toString().padLeft(3, '0')}';
    final diag = DurianSoilExpertService.diagnoseSoilStatus(currentAiPh);

    final newPoint = SoilDataPoint(
      sampleId: sampleId,
      timestamp: DateTime.now(),
      potentialMv: _potentialMv,
      temperatureC: _temperatureC,
      rawPh: currentRawPh,
      nernstPh: currentNernstPh,
      aiPh: currentAiPh,
      labStandardPh: _targetGroundTruthPh,
      siteName: '${site['village']} ${site['subdistrict']}',
      province: site['province'],
      latitude: site['lat'],
      longitude: site['lng'],
      soilType: site['soilType'],
      durianStatus: diag['status'],
      recommendedLimeKgPerRai: DurianSoilExpertService.calculateRecommendedLimeKgPerRai(
        currentPh: currentAiPh,
        soilType: site['soilType'],
      ),
    );

    _fieldSamples.insert(0, newPoint);
    notifyListeners();
  }

  String exportCalibrationDatasetCsv() {
    return DatasetGeneratorService.exportDatasetToCsv(_calibrationDataset);
  }

  String exportFieldSamplesCsv() {
    final StringBuffer csv = StringBuffer();
    csv.writeln(
        'sample_id,timestamp,potential_mv,temperature_c,raw_ph,nernst_ph,ai_ph,lab_standard_ph,site_name,province,latitude,longitude,soil_type,durian_status,recommended_lime_kg_per_rai');
    for (final s in _fieldSamples) {
      csv.writeln(
          '${s.sampleId},${s.timestamp.toIso8601String()},${s.potentialMv},${s.temperatureC},${s.rawPh},${s.nernstPh},${s.aiPh},${s.labStandardPh ?? ""},"${s.siteName}","${s.province}",${s.latitude},${s.longitude},"${s.soilType}","${s.durianStatus}",${s.recommendedLimeKgPerRai}');
    }
    return csv.toString();
  }

  @override
  void dispose() {
    _streamTimer?.cancel();
    _usbReadingSub?.cancel();
    _usbStatusSub?.cancel();
    _usbService.dispose();
    super.dispose();
  }
}
