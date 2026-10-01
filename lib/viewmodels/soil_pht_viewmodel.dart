import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../core/models/calibration_point.dart';
import '../core/models/soil_data_point.dart';
import '../core/models/hypothesis_test_result.dart';
import '../core/models/ph_sensor_reading.dart';
import '../services/nernst_physics_engine.dart';
import '../services/ai_error_compensation_model.dart';
import '../services/dataset_generator_service.dart';
import '../services/durian_soil_expert_service.dart';
import '../services/usb_soil_sensor_service.dart';
import '../services/edge_ph_model_trainer.dart';
import '../core/constants/app_constants.dart';

class SoilPhtViewModel extends ChangeNotifier {
  // Real-time sensor state
  double _potentialMv = 118.5; // Defaults around pH 5.0
  double _temperatureC = 30.0;
  bool _isStreaming = true;
  bool _isAiCompensationEnabled = true;
  Timer? _streamTimer;

  // Real-time GPS location state
  double? _liveLatitude;
  double? _liveLongitude;
  bool _isGpsActive = false;

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
    _initGps();
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

  Future<void> _initGps() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium, timeLimit: Duration(seconds: 4)),
        );
        _liveLatitude = pos.latitude;
        _liveLongitude = pos.longitude;
        _isGpsActive = true;
        notifyListeners();
      }
    } catch (_) {}
  }

  // Getters
  double get potentialMv => _potentialMv;
  double get temperatureC => _temperatureC;
  bool get isStreaming => _isStreaming;
  bool get isAiCompensationEnabled => _isAiCompensationEnabled;
  double get targetGroundTruthPh => _targetGroundTruthPh;

  // GPS getters
  double? get liveLatitude => _liveLatitude;
  double? get liveLongitude => _liveLongitude;
  bool get isGpsActive => _isGpsActive;

  // USB Status & Parameters
  UsbStatus get usbStatus => _usbStatus;
  bool get isUsbConnected => _usbStatus == UsbStatus.connected;
  double get usbMoisture => _usbMoisture;
  int get usbEc => _usbEc;
  double get usbRawPh => _usbRawPh;
  int get usbBaudRate => _usbService.currentBaudRate;
  String get usbStatusMessage => _usbService.statusMessage;
  String get usbLastHexRx => _usbService.lastHexRx;
  String get usbLastHexTx => _usbService.lastHexTx;

  double get currentNernstSlope =>
      NernstPhysicsEngine.calculateNernstSlopeMv(_temperatureC);

  double get currentRawPh {
    if (isUsbConnected) {
      return _usbRawPh;
    }
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
      if (isUsbConnected) return;
      _updateSimulatedReading();
    });
  }

  void _updateSimulatedReading() {
    final Random rng = Random();
    final double tempJitter = (rng.nextDouble() - 0.5) * 0.4;
    _temperatureC = double.parse((_temperatureC + tempJitter).clamp(18.0, 48.0).toStringAsFixed(1));

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

  Future<bool> connectUsb() async {
    final success = await _usbService.autoConnect();
    notifyListeners();
    return success;
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

  Future<void> logCurrentFieldSample() async {
    final site = currentTargetSite;
    final String sampleId =
        'SMP-NEW-${(_fieldSamples.length + 1).toString().padLeft(3, '0')}';
    final diag = DurianSoilExpertService.diagnoseSoilStatus(currentAiPh);

    // Read real-time GPS coordinates if available, otherwise use target site coordinates
    double currentLat = site['lat'] as double;
    double currentLng = site['lng'] as double;

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 3)),
          );
          currentLat = double.parse(pos.latitude.toStringAsFixed(6));
          currentLng = double.parse(pos.longitude.toStringAsFixed(6));
          _liveLatitude = currentLat;
          _liveLongitude = currentLng;
          _isGpsActive = true;
        }
      }
    } catch (_) {}

    final newPoint = SoilDataPoint(
      sampleId: sampleId,
      timestamp: DateTime.now(),
      potentialMv: _potentialMv,
      temperatureC: _temperatureC,
      rawPh: currentRawPh,
      nernstPh: currentNernstPh,
      aiPh: currentAiPh,
      labStandardPh: _targetGroundTruthPh,
      siteName: _isGpsActive
          ? '${site['village']} (GPS Live)'
          : '${site['village']} ${site['subdistrict']}',
      province: site['province'],
      latitude: currentLat,
      longitude: currentLng,
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


  // On-Device Edge ML State
  EdgeMlTrainingResult? _edgeMlResult;
  bool _isTrainingOnDevice = false;

  EdgeMlTrainingResult? get edgeMlResult => _edgeMlResult;
  bool get isTrainingOnDevice => _isTrainingOnDevice;
  bool get isUsingCustomEdgeModel => AiErrorCompensationModel.isUsingCustomModel;

  Future<EdgeMlTrainingResult> trainEdgeModelOnDevice() async {
    _isTrainingOnDevice = true;
    notifyListeners();
    try {
      final trainPoints = _calibrationDataset.where((p) => p.split == 'train').toList();
      final result = await EdgePhModelTrainer.trainModel(trainingPoints: trainPoints);
      _edgeMlResult = result;
      return result;
    } finally {
      _isTrainingOnDevice = false;
      notifyListeners();
    }
  }

  void applyEdgeModel(EdgeMlTrainingResult result) {
    AiErrorCompensationModel.setCustomWeights(result.weights);
    notifyListeners();
  }

  void resetEdgeModelToBaseline() {
    AiErrorCompensationModel.resetToDefaultWeights();
    _edgeMlResult = null;
    notifyListeners();
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
