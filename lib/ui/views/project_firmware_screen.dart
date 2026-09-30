import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../services/ai_error_compensation_model.dart';
import '../widgets/glassmorphic_card.dart';

class ProjectFirmwareScreen extends StatelessWidget {
  const ProjectFirmwareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String cppCode = AiErrorCompensationModel.generateCppArduinoCode();
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('เฟิร์มแวร์ ESP32 & ข้อมูลโครงการวิจัย', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('ขั้นตอนที่ 4.1 : การฝังโมเดล AI ลงในไมโครคอนโทรลเลอร์', style: TextStyle(fontSize: 11, color: AppTheme.primaryCyan)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Research Proposal Header Card
            _buildProjectSummaryCard(),
            const SizedBox(height: 12),

            // Research Team Members Card
            _buildResearchTeamCard(),
            const SizedBox(height: 12),

            // Hardware Wiring Table
            _buildHardwarePinoutCard(),
            const SizedBox(height: 12),

            // Embedded AI Firmware C++ Code Box
            _buildFirmwareCodeBox(context, cppCode),
            const SizedBox(height: 12),

            // Academic References
            _buildReferencesCard(),
            const SizedBox(height: 12),

            // Developer & Research Unit Attribution Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, size: 16, color: AppTheme.primaryEmerald),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'เอกสารและระบบนี้จัดทำขึ้นโดย ${AppConstants.developedBy}',
                      style: const TextStyle(fontSize: 10, color: AppTheme.mutedText, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSummaryCard() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryEmerald.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.school, size: 20, color: AppTheme.primaryEmerald),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  AppConstants.fundingBody,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryEmerald),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            AppConstants.projectTitleTh,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, height: 1.3),
          ),
          const SizedBox(height: 4),
          const Text(
            AppConstants.projectTitleEn,
            style: TextStyle(fontSize: 11, color: AppTheme.mutedText, fontStyle: FontStyle.italic),
          ),
          const Divider(color: Colors.white12, height: 16),
          Row(
            children: [
              Expanded(child: _buildMetaItem('ปีงบประมาณ', 'พ.ศ. 2569')),
              Expanded(child: _buildMetaItem('งบประมาณวิจัย', AppConstants.totalBudget)),
              Expanded(child: _buildMetaItem('สถานะต้นแบบ', 'Hardware + AI')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: AppTheme.mutedText)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentNeon)),
        ),
      ],
    );
  }

  Widget _buildResearchTeamCard() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people_alt, size: 16, color: AppTheme.primaryCyan),
              SizedBox(width: 6),
              Expanded(
                child: Text('คณะผู้วิจัยและผู้รับผิดชอบโครงการ', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...AppConstants.researchers.map((r) => _buildResearcherRow(r)),
        ],
      ),
    );
  }

  Widget _buildResearcherRow(Map<String, String> r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    r['name']!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.neutralText),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      r['role']!,
                      style: const TextStyle(fontSize: 10, color: AppTheme.primaryEmerald, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(r['dept']!, style: const TextStyle(fontSize: 10, color: AppTheme.mutedText)),
            const SizedBox(height: 2),
            Text('หน้าที่: ${r['responsibility']!}', style: const TextStyle(fontSize: 10, color: AppTheme.accentNeon)),
          ],
        ),
      ),
    );
  }

  Widget _buildHardwarePinoutCard() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.memory, size: 16, color: AppTheme.warningOrange),
              SizedBox(width: 6),
              Expanded(
                child: Text('แผนผังการเชื่อมต่อวงจรอิเล็กทรอนิกส์', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPinRow('ขั้ววัดศักย์ไฟฟ้า pH (Electrode)', 'Analog Signal', 'GPIO 34 (ADC1_CH6)'),
          _buildPinRow('เซนเซอร์วัดอุณหภูมิ DS18B20', 'OneWire Bus', 'GPIO 4 (Pull-up 4.7kΩ)'),
          _buildPinRow('จอแสดงผล I2C OLED (SSD1306)', 'SDA / SCL', 'GPIO 21 / GPIO 22'),
          _buildPinRow('พอร์ตส่งข้อมูล USB Serial / BLE', 'UART / BLE', 'TX0 / RX0 @ 115200'),
        ],
      ),
    );
  }

  Widget _buildPinRow(String device, String signal, String pin) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(device, style: const TextStyle(fontSize: 11, color: AppTheme.neutralText)),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 2,
            child: Text(signal, style: const TextStyle(fontSize: 10, color: AppTheme.mutedText)),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                pin,
                textAlign: TextAlign.end,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.accentNeon),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirmwareCodeBox(BuildContext context, String code) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.code, size: 16, color: AppTheme.primaryEmerald),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text('โค้ดฝังบอร์ด ESP32 C++ (Step 4.1)', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18, color: AppTheme.primaryEmerald),
                tooltip: 'คัดลอกโค้ด C++',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppTheme.surfaceCard,
                      content: Text('คัดลอกโค้ด C++ สำหรับ ESP32 เรียบร้อยแล้ว', style: TextStyle(color: AppTheme.accentNeon)),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 180,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: SingleChildScrollView(
              child: Text(
                code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: AppTheme.neutralText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferencesCard() {
    return GlassmorphicCard(
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.library_books, size: 16, color: AppTheme.primaryCyan),
              SizedBox(width: 6),
              Expanded(
                child: Text('เอกสารอ้างอิงทางวิชาการ (Academic References)', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Chen, L., Zhang, Y., & Wang, H. (2023). Advanced calibration of potentiometric sensors using neural networks for real-time environmental monitoring. Sensors and Actuators B: Chemical, 378, 133125.\n'
            '• Phimsorn, P., Suksaran, R., & Thongpae, S. (2023). Effects of soil acidity on nutrient uptake and growth of durian (Durio zibethinus Murr.) in Eastern Thailand. Agriculture and Natural Resources, 57(4), 681-690.\n'
            '• Jie, Y., Liu, J., Zhang, J., & Li, D. (2022). A review of machine learning in agricultural soil property prediction. Computers and Electronics in Agriculture, 197, 106955.\n'
            '• Zarychta, A., & Gródek, J. (2024). The role of IoT and AI in modern precision agriculture: A systematic review. Computers and Electronics in Agriculture, 218, 108650.',
            style: TextStyle(fontSize: 10, color: AppTheme.mutedText, height: 1.4),
          ),
        ],
      ),
    );
  }
}
