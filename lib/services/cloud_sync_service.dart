import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/models/calibration_point.dart';
import '../core/models/soil_data_point.dart';

class CloudSyncResult {
  final bool isSuccess;
  final String message;
  final String? localFilePath;
  final int recordCount;

  CloudSyncResult({
    required this.isSuccess,
    required this.message,
    this.localFilePath,
    required this.recordCount,
  });
}

class CloudSyncService {
  /// Export calibration dataset to CSV and share directly (Google Drive, Gmail, Files)
  static Future<CloudSyncResult> shareCalibrationDatasetCsv(List<CalibrationPoint> points) async {
    try {
      final StringBuffer csv = StringBuffer();
      csv.writeln('id,potential_mv,temperature_c,standard_ph,nernst_ph,ai_predicted_ph,traditional_error,ai_error,split,timestamp');
      for (final p in points) {
        csv.writeln(
          '${p.id},${p.potentialMv},${p.temperatureC},${p.standardPh},${p.nernstPh},${p.aiPredictedPh},${p.traditionalError.toStringAsFixed(4)},${p.aiError.toStringAsFixed(4)},${p.split},${p.timestamp.toIso8601String()}',
        );
      }

      final Directory dir = await getTemporaryDirectory();
      final String filePath = '${dir.path}/soil_ai_calibration_dataset_${DateTime.now().millisecondsSinceEpoch}.csv';
      final File file = File(filePath);
      await file.writeAsString(csv.toString());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv')],
          text: 'SoilpHTxAI Research Calibration Dataset (RBRU 2569) - ${points.length} records',
          subject: 'SoilpHTxAI Calibration Dataset CSV',
        ),
      );

      return CloudSyncResult(
        isSuccess: true,
        message: 'ส่งออกไฟล์ CSV สำหรับ Google Drive เรียบร้อยแล้ว',
        localFilePath: file.path,
        recordCount: points.length,
      );
    } catch (e) {
      return CloudSyncResult(
        isSuccess: false,
        message: 'เกิดข้อผิดพลาดในการส่งออก: $e',
        recordCount: 0,
      );
    }
  }

  /// Export Field Survey soil samples to JSON and share
  static Future<CloudSyncResult> shareFieldSurveyJson(List<SoilDataPoint> surveys) async {
    try {
      final List<Map<String, dynamic>> jsonList = surveys.map((s) => s.toMap()).toList();
      final String jsonStr = const JsonEncoder.withIndent('  ').convert({
        'project': 'SoilpHTxAI - Rambhai Barni Rajabhat University',
        'exported_at': DateTime.now().toIso8601String(),
        'record_count': surveys.length,
        'records': jsonList,
      });

      final Directory dir = await getTemporaryDirectory();
      final String filePath = '${dir.path}/soil_survey_field_data_${DateTime.now().millisecondsSinceEpoch}.json';
      final File file = File(filePath);
      await file.writeAsString(jsonStr);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          text: 'SoilpHTxAI Field Survey Data (GPS & Telemetry) - ${surveys.length} samples',
          subject: 'SoilpHTxAI Field Survey JSON',
        ),
      );

      return CloudSyncResult(
        isSuccess: true,
        message: 'ส่งออกไฟล์ JSON สำเร็จแล้ว',
        localFilePath: file.path,
        recordCount: surveys.length,
      );
    } catch (e) {
      return CloudSyncResult(
        isSuccess: false,
        message: 'เกิดข้อผิดพลาดในการส่งออก: $e',
        recordCount: 0,
      );
    }
  }
}
