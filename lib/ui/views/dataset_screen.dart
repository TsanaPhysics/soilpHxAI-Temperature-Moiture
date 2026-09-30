import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/calibration_point.dart';
import '../../core/utils/responsive.dart';
import '../../viewmodels/soil_pht_viewmodel.dart';
import '../../services/cloud_sync_service.dart';
import '../widgets/glassmorphic_card.dart';

class DatasetScreen extends StatefulWidget {
  const DatasetScreen({super.key});

  @override
  State<DatasetScreen> createState() => _DatasetScreenState();
}

class _DatasetScreenState extends State<DatasetScreen> {
  String _selectedFilter = 'all'; // 'all', 'train', 'val', 'test'

  void _showEdgeMlTrainingDialog(BuildContext context, SoilPhtViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final edgeResult = vm.edgeMlResult;
            final isTraining = vm.isTrainingOnDevice;
            final isUsingCustom = vm.isUsingCustomEdgeModel;

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Color(0xFF131F17),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppTheme.primaryEmerald, width: 2)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryEmerald.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryEmerald),
                        ),
                        child: const Icon(Icons.psychology, color: AppTheme.primaryEmerald, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pure Dart Edge ML Trainer',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              isUsingCustom
                                  ? 'กำลังใช้งาน: โมเดลปรับจูนเฉพาะตัวเครื่อง (Custom ML)'
                                  : 'กำลังใช้งาน: ค่ามาตรฐานการวิจัย (RBRU Baseline)',
                              style: TextStyle(
                                fontSize: 11,
                                color: isUsingCustom ? AppTheme.accentNeon : AppTheme.primaryCyan,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Information banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'การฝึกฝนโมเดล AI เกิดขึ้นบนตัวประมวลผลของสมาร์ทโฟนโดยตรง (Zero Server Dependency) คำนวณสมการ Normal Equation สำหรับฟิตโมเดลพหุนามที่ไม่เป็นเชิงเส้น (Non-linear Polynomial Regression) เข้ากับค่าบัฟเฟอร์มาตรฐาน',
                      style: TextStyle(fontSize: 11, color: AppTheme.mutedText, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Training action button
                  ElevatedButton.icon(
                    onPressed: isTraining
                        ? null
                        : () async {
                            setModalState(() {});
                            await vm.trainEdgeModelOnDevice();
                            setModalState(() {});
                          },
                    icon: isTraining
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Icon(Icons.auto_mode, color: Colors.black),
                    label: Text(
                      isTraining ? 'กำลังประมวลผล OLS Normal Equation...' : 'เริ่มฝึกฝนโมเดลใหม่ (Train Model On-Device)',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryEmerald,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Training Results Section
                  if (edgeResult != null) ...[
                    const Text('ผลการประเมินโมเดลบนตัวเครื่อง (On-Device Metrics):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildMetricBox('R² Score', edgeResult.r2.toStringAsFixed(4), AppTheme.primaryEmerald),
                        const SizedBox(width: 8),
                        _buildMetricBox('RMSE', '${edgeResult.rmse.toStringAsFixed(4)} pH', AppTheme.primaryCyan),
                        const SizedBox(width: 8),
                        _buildMetricBox('MAE', '${edgeResult.mae.toStringAsFixed(4)} pH', AppTheme.accentNeon),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('จำนวนตัวอย่างฝึกสอน: ${edgeResult.sampleCount} จุด', style: const TextStyle(fontSize: 11, color: AppTheme.mutedText)),
                              Text('เวลาที่ใช้: ${edgeResult.trainingDuration.inMilliseconds} ms', style: const TextStyle(fontSize: 11, color: AppTheme.primaryEmerald)),
                            ],
                          ),
                          const Divider(color: Colors.white10, height: 16),
                          const Text('ค่าน้ำหนักสัมประสิทธิ์โมเดล (Trained Weights):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.neutralText)),
                          const SizedBox(height: 4),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              'Bias: ${edgeResult.weights[0].toStringAsFixed(5)} | cE: ${edgeResult.weights[1].toStringAsFixed(6)} | cT: ${edgeResult.weights[2].toStringAsFixed(6)} | cET: ${edgeResult.weights[3].toStringAsExponential(3)}',
                              style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppTheme.primaryCyan),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              vm.resetEdgeModelToBaseline();
                              setModalState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('รีเซ็ตโมเดลกลับสู่ค่ามาตรฐานการวิจัยเรียบร้อยแล้ว')),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.dangerRose,
                              side: const BorderSide(color: AppTheme.dangerRose),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('รีเซ็ตสู่ค่าเริ่มต้น'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              vm.applyEdgeModel(edgeResult);
                              setModalState(() {});
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppTheme.primaryEmerald,
                                  content: Text('เปิดใช้งานโมเดล AI ที่เทรนบนเครื่องสำหรับการวัดผลสดแล้ว!'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryEmerald,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('นำไปใช้งานทันที', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Spacer(),
                    Center(
                      child: Text(
                        'กดปุ่ม "เริ่มฝึกฝนโมเดลใหม่" เพื่อเริ่มต้นคำนวณ Normal Equation',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
                      ),
                    ),
                    const Spacer(),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMetricBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SoilPhtViewModel>(context);
    final allPoints = vm.calibrationDataset;
    final padding = Responsive.horizontalPadding(context);

    final trainCount = allPoints.where((p) => p.split == 'train').length;
    final valCount = allPoints.where((p) => p.split == 'val').length;
    final testCount = allPoints.where((p) => p.split == 'test').length;

    final filteredPoints = _selectedFilter == 'all'
        ? allPoints
        : allPoints.where((p) => p.split == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ชุดข้อมูลสอบเทียบในห้องปฏิบัติการ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('ขั้นตอนที่ 2: Standard Buffers 4.01, 7.00, 10.01 @ 20-50°C', style: TextStyle(fontSize: 11, color: AppTheme.primaryCyan)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'ฝึกฝนโมเดล AI บนเครื่อง (Edge ML)',
            icon: const Icon(Icons.psychology, color: AppTheme.primaryEmerald),
            onPressed: () => _showEdgeMlTrainingDialog(context, vm),
          ),
          IconButton(
            tooltip: 'ส่งออกข้อมูลขึ้น Google Drive / Cloud .CSV',
            icon: const Icon(Icons.cloud_upload_outlined, color: AppTheme.primaryCyan),
            onPressed: () async {
              final result = await CloudSyncService.shareCalibrationDatasetCsv(allPoints);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: result.isSuccess ? AppTheme.surfaceCard : AppTheme.dangerRose,
                    content: Text(result.message),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Edge ML & Dataset Summary Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
            child: GlassmorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'การกระจายตัวของข้อมูลสอบเทียบ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: vm.isUsingCustomEdgeModel
                              ? AppTheme.accentNeon.withValues(alpha: 0.2)
                              : AppTheme.primaryCyan.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: vm.isUsingCustomEdgeModel ? AppTheme.accentNeon : AppTheme.primaryCyan,
                          ),
                        ),
                        child: Text(
                          vm.isUsingCustomEdgeModel ? '🧠 Custom ML' : '📊 Baseline',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: vm.isUsingCustomEdgeModel ? AppTheme.accentNeon : AppTheme.primaryCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSplitBadge('Train (70%)', trainCount, AppTheme.primaryEmerald),
                      const SizedBox(width: 8),
                      _buildSplitBadge('Val (15%)', valCount, AppTheme.primaryCyan),
                      const SizedBox(width: 8),
                      _buildSplitBadge('Test (15%)', testCount, AppTheme.warningOrange),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showEdgeMlTrainingDialog(context, vm),
                      icon: const Icon(Icons.model_training, size: 16, color: AppTheme.primaryEmerald),
                      label: const Text(
                        'เปิดระบบฝึกฝนโมเดล AI บนเครื่อง (Edge ML Trainer)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryEmerald),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryEmerald),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
            child: Row(
              children: [
                _buildFilterChip('ทั้งหมด (${allPoints.length})', 'all'),
                const SizedBox(width: 6),
                _buildFilterChip('ชุดฝึกสอน Training ($trainCount)', 'train'),
                const SizedBox(width: 6),
                _buildFilterChip('ชุดตรวจสอบ Validation ($valCount)', 'val'),
                const SizedBox(width: 6),
                _buildFilterChip('ชุดทดสอบ Test ($testCount)', 'test'),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Responsive Data Table with smooth horizontal scroll to prevent overflow on any phone width
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 560, // Guaranteed comfortable width for all 6 columns
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: AppTheme.surfaceCard,
                      child: const Row(
                        children: [
                          SizedBox(width: 90, child: Text('ID / Split', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.mutedText))),
                          SizedBox(width: 85, child: Text('ศักย์ (mV)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.mutedText))),
                          SizedBox(width: 80, child: Text('อุณหภูมิ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.mutedText))),
                          SizedBox(width: 85, child: Text('pH บัฟเฟอร์', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.mutedText))),
                          SizedBox(width: 85, child: Text('pH AI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryEmerald))),
                          SizedBox(width: 85, child: Text('AI Error', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.accentNeon))),
                        ],
                      ),
                    ),

                    // Data rows
                    Expanded(
                      child: ListView.separated(
                        itemCount: filteredPoints.length,
                        separatorBuilder: (_, index) => const Divider(color: Colors.white10, height: 1),
                        itemBuilder: (context, index) {
                          final CalibrationPoint p = filteredPoints[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 90,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.id, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      Text(
                                        p.split.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: p.split == 'train'
                                              ? AppTheme.primaryEmerald
                                              : p.split == 'val'
                                                  ? AppTheme.primaryCyan
                                                  : AppTheme.warningOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 85, child: Text('${p.potentialMv.toStringAsFixed(1)} mV', style: const TextStyle(fontSize: 11))),
                                SizedBox(width: 80, child: Text('${p.temperatureC.toStringAsFixed(1)} °C', style: const TextStyle(fontSize: 11))),
                                SizedBox(width: 85, child: Text(p.standardPh.toStringAsFixed(2), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                                SizedBox(
                                  width: 85,
                                  child: Text(
                                    p.aiPredictedPh.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryEmerald),
                                  ),
                                ),
                                SizedBox(
                                  width: 85,
                                  child: Text(
                                    '±${p.aiError.toStringAsFixed(3)}',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.accentNeon),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitBadge(String title, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(title, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('$count รายการ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final bool isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.black : AppTheme.neutralText)),
      selected: isSelected,
      selectedColor: AppTheme.primaryEmerald,
      backgroundColor: AppTheme.surfaceCard,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = value;
          });
        }
      },
    );
  }
}
