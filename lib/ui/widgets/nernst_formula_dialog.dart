import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/nernst_physics_engine.dart';

class NernstFormulaDialog extends StatelessWidget {
  final double currentTemp;
  final double currentPotential;

  const NernstFormulaDialog({
    super.key,
    required this.currentTemp,
    required this.currentPotential,
  });

  @override
  Widget build(BuildContext context) {
    final double slope = NernstPhysicsEngine.calculateNernstSlopeMv(currentTemp);

    return AlertDialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
      ),
      title: Row(
        children: [
          const Icon(Icons.functions, color: AppTheme.primaryCyan),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'สมการเนินสต์ & ทฤษฎีเคมีไฟฟ้า',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.2)),
              ),
              child: const Text(
                'E = E⁰ - (2.303·R·T / n·F) · pH\n'
                'pH = 7.0 - (E_real - E⁰) / S(T)',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: AppTheme.accentNeon,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildParamRow('อุณหภูมิปัจจุบัน (T):', '${currentTemp.toStringAsFixed(1)} °C (${(currentTemp + 273.15).toStringAsFixed(1)} K)'),
            _buildParamRow('ความชันเชิงทฤษฎี S(T):', '${slope.toStringAsFixed(2)} mV/pH'),
            _buildParamRow('ความต่างศักย์วัดได้ (E_real):', '${currentPotential.toStringAsFixed(1)} mV'),
            const Divider(color: Colors.white24, height: 24),
            const Text(
              'ทำไมต้องใช้ปัญญาประดิษฐ์ (AI)?',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.warningOrange),
            ),
            const SizedBox(height: 6),
            const Text(
              'สมการเนินสต์แบบดั้งเดิมถือว่าเซนเซอร์มีการตอบสนองเป็นเส้นตรงสมบูรณ์ แต่ในความเป็นจริง เยื่อแก้ว (Glass Membrane) มีความไม่เป็นเชิงเส้น (Non-linearity), ปรากฏการณ์ Asymmetry Potential Drift ตามอุณหภูมิ, และการเสื่อมสภาพ\n\n'
              'แบบจำลอง AI (ANN) ในโครงการนี้ทำหน้าที่เป็น Inverse Mapping Function: g(E_real, T) ช่วยกำจัดความคลาดเคลื่อนได้อย่างแม่นยำเทียบเท่าเครื่องวัดระดับห้องปฏิบัติการ',
              style: TextStyle(fontSize: 12, color: AppTheme.neutralText, height: 1.4),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('เข้าใจแล้ว', style: TextStyle(color: AppTheme.primaryEmerald)),
        ),
      ],
    );
  }

  Widget _buildParamRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.mutedText)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.neutralText)),
        ],
      ),
    );
  }
}
