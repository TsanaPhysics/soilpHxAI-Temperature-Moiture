import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../services/durian_soil_expert_service.dart';
import '../../services/usb_soil_sensor_service.dart';
import '../../viewmodels/soil_pht_viewmodel.dart';
import '../widgets/glassmorphic_card.dart';
import '../widgets/ph_circular_gauge.dart';
import '../widgets/nernst_formula_dialog.dart';
import 'soil_camera_screen.dart';

class LiveMonitorScreen extends StatelessWidget {
  const LiveMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SoilPhtViewModel>(context);
    final diag = vm.currentDurianDiagnosis;
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SoilpHTxAI Live Field Monitor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              '${vm.currentTargetSite['village']} ${vm.currentTargetSite['province']}',
              style: const TextStyle(fontSize: 11, color: AppTheme.primaryCyan),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'กล้องบันทึกภาพดิน (Soil Vision)',
            icon: const Icon(Icons.camera_alt, color: AppTheme.accentNeon),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SoilCameraScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'ทฤษฎีสมการเนินสต์',
            icon: const Icon(Icons.menu_book, color: AppTheme.primaryCyan),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => NernstFormulaDialog(
                  currentTemp: vm.temperatureC,
                  currentPotential: vm.potentialMv,
                ),
              );
            },
          ),
          IconButton(
            tooltip: vm.isStreaming ? 'หยุดการสตรีม' : 'เริ่มสตรีมข้อมูล',
            icon: Icon(
              vm.isStreaming ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: vm.isStreaming ? AppTheme.primaryEmerald : AppTheme.warningOrange,
            ),
            onPressed: vm.toggleStreaming,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // USB-C Sensor Connection Status Bar
            _buildUsbConnectionCard(context, vm),
            const SizedBox(height: 10),

            // AI Compensation Toggle Banner
            _buildAiStatusBanner(context, vm),
            const SizedBox(height: 12),

            // Main Display Gauge
            _buildMainGaugeCard(context, vm, diag),
            const SizedBox(height: 12),

            // Physical Signals Grid (Potential, Temp, Slope + USB Moisture/EC)
            _buildSignalsGrid(context, vm),
            const SizedBox(height: 12),

            // Side-by-Side Compensation Comparison Card
            _buildComparisonCard(context, vm),
            const SizedBox(height: 12),

            // Durian Soil Health & Liming Card
            _buildDurianHealthCard(context, vm, diag),
            const SizedBox(height: 12),

            // Field Simulator & Interactive Controls (Disabled when USB connected)
            _buildSimulatorCard(context, vm),
            const SizedBox(height: 16),

            // Quick Log Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryEmerald,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              icon: const Icon(Icons.bookmark_add, size: 22),
              label: Text(
                vm.isUsbConnected ? 'บันทึกตัวอย่างดิน USB-C (Log Sample)' : 'บันทึกตัวอย่างดินภาคสนาม (Log Sample)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                vm.logCurrentFieldSample();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.surfaceCard,
                    content: Text(
                      'บันทึกตัวอย่างดิน ${vm.currentTargetSite['village']} สำเร็จ (pH: ${vm.currentAiPh.toStringAsFixed(2)})',
                      style: const TextStyle(color: AppTheme.accentNeon),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUsbConnectionCard(BuildContext context, SoilPhtViewModel vm) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (vm.usbStatus) {
      case UsbStatus.connected:
        statusColor = AppTheme.primaryEmerald;
        statusIcon = Icons.usb;
        statusText = 'เชื่อมต่อแล้ว (RS485)';
        break;
      case UsbStatus.connecting:
        statusColor = AppTheme.primaryCyan;
        statusIcon = Icons.sync;
        statusText = 'กำลังค้นหาพอร์ต USB...';
        break;
      case UsbStatus.error:
        statusColor = AppTheme.dangerRose;
        statusIcon = Icons.error_outline;
        statusText = 'ไม่สำเร็จ';
        break;
      case UsbStatus.disconnected:
        statusColor = AppTheme.mutedText;
        statusIcon = Icons.usb_off;
        statusText = 'ไม่ได้เชื่อมต่อ (Sim)';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: vm.isUsbConnected ? AppTheme.primaryEmerald.withValues(alpha: 0.5) : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'พอร์ต USB-C ',
                      style: TextStyle(fontSize: 11, color: AppTheme.mutedText),
                    ),
                    Expanded(
                      child: Text(
                        statusText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  vm.isUsbConnected
                      ? 'Baud Rate: ${vm.usbBaudRate} bps | Modbus RTU 0x01'
                      : vm.usbStatusMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: vm.usbStatus == UsbStatus.error ? AppTheme.dangerRose : AppTheme.neutralText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: vm.isUsbConnected ? 'ตัดการเชื่อมต่อ USB' : 'ค้นหาเซนเซอร์ USB-C',
            icon: Icon(
              vm.isUsbConnected ? Icons.link_off : Icons.refresh,
              color: vm.isUsbConnected ? AppTheme.warningOrange : AppTheme.primaryCyan,
              size: 20,
            ),
            onPressed: () async {
              if (vm.isUsbConnected) {
                await vm.disconnectUsb();
              } else {
                final success = await vm.connectUsb();
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('💡 คำแนะนำ: หากเสียบสาย USB-C แล้วยังไม่เชื่อมต่อ ให้เปิด "การเชื่อมต่อ OTG" ในการตั้งค่าสมาร์ทโฟน และตรวจสอบไฟเลี้ยงเซนเซอร์ (5V-12V)'),
                      backgroundColor: AppTheme.warningOrange,
                      duration: Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAiStatusBanner(BuildContext context, SoilPhtViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: vm.isAiCompensationEnabled
            ? AppTheme.primaryEmerald.withValues(alpha: 0.15)
            : AppTheme.warningOrange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: vm.isAiCompensationEnabled ? AppTheme.primaryEmerald : AppTheme.warningOrange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            vm.isAiCompensationEnabled ? Icons.auto_awesome : Icons.science_outlined,
            color: vm.isAiCompensationEnabled ? AppTheme.accentNeon : AppTheme.warningOrange,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              vm.isAiCompensationEnabled
                  ? 'AI ชดเชย เปิด (R² 0.999)'
                  : 'Nernst มาตรฐาน',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: vm.isAiCompensationEnabled ? AppTheme.accentNeon : AppTheme.warningOrange,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: vm.isAiCompensationEnabled,
              activeThumbColor: AppTheme.accentNeon,
              onChanged: (_) => vm.toggleAiCompensation(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainGaugeCard(BuildContext context, SoilPhtViewModel vm, Map<String, dynamic> diag) {
    final double ph = vm.displayedPh;
    final double raw = vm.currentRawPh;
    final double delta = ph - raw;

    return PhCircularGauge(
      currentPh: ph,
      rawPh: raw,
      isAiActive: vm.isAiCompensationEnabled,
      deltaPh: delta,
    );
  }

  Widget _buildSignalsGrid(BuildContext context, SoilPhtViewModel vm) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                icon: Icons.electric_bolt,
                label: 'ศักย์ (E)',
                value: '${vm.potentialMv.toStringAsFixed(1)} mV',
                color: AppTheme.primaryCyan,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                icon: Icons.thermostat,
                label: 'อุณหภูมิ (T)',
                value: '${vm.temperatureC.toStringAsFixed(1)} °C',
                color: AppTheme.warningOrange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                icon: Icons.show_chart,
                label: 'Nernst Slope',
                value: '${vm.currentNernstSlope.toStringAsFixed(1)} mV',
                color: AppTheme.accentNeon,
              ),
            ),
          ],
        ),
        // Additional RS485 Parameter Row (Moisture & EC)
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                icon: Icons.water_drop,
                label: 'ความชื้นดิน',
                value: '${vm.usbMoisture.toStringAsFixed(1)} %',
                color: AppTheme.primaryCyan,
                badge: vm.isUsbConnected ? 'Live' : 'Sim',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                icon: Icons.bolt,
                label: 'ความนำไฟฟ้า',
                value: '${vm.usbEc} µS/cm',
                color: AppTheme.primaryEmerald,
                badge: vm.isUsbConnected ? 'Live' : 'Sim',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppTheme.mutedText),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(fontSize: 8, color: color, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(BuildContext context, SoilPhtViewModel vm) {
    final double raw = vm.currentRawPh;
    final double nernst = vm.currentNernstPh;
    final double ai = vm.currentAiPh;
    final double errorRaw = (raw - vm.targetGroundTruthPh).abs();
    final double errorNernst = (nernst - vm.targetGroundTruthPh).abs();
    final double errorAi = (ai - vm.targetGroundTruthPh).abs();

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'เปรียบเทียบการชดเชยค่าผิดพลาด (Compensation Benchmark)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildComparisonColumn(
                  title: 'Raw Sensor',
                  phValue: raw,
                  error: errorRaw,
                  color: AppTheme.dangerRose,
                  desc: 'ไม่ชดเชยอุณหภูมิ',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildComparisonColumn(
                  title: 'Pure Nernst',
                  phValue: nernst,
                  error: errorNernst,
                  color: AppTheme.warningOrange,
                  desc: 'ชดเชยเชิงเส้น T',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildComparisonColumn(
                  title: 'AI Pipeline',
                  phValue: ai,
                  error: errorAi,
                  color: AppTheme.accentNeon,
                  desc: 'ชดเชยฟิสิกส์+AI',
                  isBest: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonColumn({
    required String title,
    required double phValue,
    required double error,
    required Color color,
    required String desc,
    bool isBest = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isBest ? color : Colors.white10,
          width: isBest ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              phValue.toStringAsFixed(2),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: color),
            ),
          ),
          Text(
            'Err: ±${error.toStringAsFixed(3)}',
            style: const TextStyle(fontSize: 9, color: AppTheme.mutedText),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 8, color: AppTheme.neutralText),
          ),
        ],
      ),
    );
  }

  Widget _buildDurianHealthCard(BuildContext context, SoilPhtViewModel vm, Map<String, dynamic> diag) {
    final double limeAmount = DurianSoilExpertService.calculateRecommendedLimeKgPerRai(
      currentPh: vm.displayedPh,
      soilType: vm.currentTargetSite['soilType'],
    );

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.eco, size: 16, color: AppTheme.primaryEmerald),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'คำวินิจฉัยสุขภาพดินสำหรับทุเรียน (Durian Agronomy)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            diag['description'],
            style: const TextStyle(fontSize: 11, color: AppTheme.neutralText, height: 1.35),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.accentNeon.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.tips_and_updates, size: 15, color: AppTheme.warningOrange),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'แนวทางจัดการ ${diag['action']} (แนะนำปูนโดโลไมต์ $limeAmount กก./ไร่)',
                    style: const TextStyle(fontSize: 11, color: AppTheme.accentNeon, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatorCard(BuildContext context, SoilPhtViewModel vm) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: const Text(
                  'จำลองสภาพดินภาคสนาม (Field Simulator)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              if (vm.isUsbConnected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryEmerald.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'USB Active',
                    style: TextStyle(fontSize: 9, color: AppTheme.accentNeon, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: vm.selectedSiteIndex,
                dropdownColor: AppTheme.surfaceCard,
                items: const [
                  DropdownMenuItem(
                    value: 0,
                    child: Text('หมู่บ้านหนองอ้อ ตำบลมะขาม (จันทบุรี)', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text('บ้านหนองตาลิ่น ตำบลสองพี่น้อง (จันทบุรี)', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                  ),
                  DropdownMenuItem(
                    value: 2,
                    child: Text('หมู่บ้านตาละวาย ตำบลประณีต (ตราด)', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) vm.selectTargetSite(val);
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'pH อ้างอิง ${vm.targetGroundTruthPh.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppTheme.mutedText),
                ),
              ),
              Flexible(
                child: Text(
                  'อุณหภูมิ ${vm.temperatureC.toStringAsFixed(1)} °C',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppTheme.mutedText),
                ),
              ),
            ],
          ),
          Slider(
            value: vm.targetGroundTruthPh,
            min: 3.5,
            max: 8.5,
            divisions: 50,
            activeColor: AppTheme.primaryEmerald,
            onChanged: vm.isUsbConnected ? null : (v) => vm.setTargetGroundTruthPh(v),
          ),
        ],
      ),
    );
  }
}
