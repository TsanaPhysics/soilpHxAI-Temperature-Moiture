import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/calibration_point.dart';
import '../../core/utils/responsive.dart';
import '../../viewmodels/soil_pht_viewmodel.dart';
import '../widgets/glassmorphic_card.dart';

class DatasetScreen extends StatefulWidget {
  const DatasetScreen({super.key});

  @override
  State<DatasetScreen> createState() => _DatasetScreenState();
}

class _DatasetScreenState extends State<DatasetScreen> {
  String _selectedFilter = 'all'; // 'all', 'train', 'val', 'test'

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
            tooltip: 'ส่งออกชุดข้อมูล .CSV',
            icon: const Icon(Icons.share, color: AppTheme.primaryEmerald),
            onPressed: () {
              final csvData = vm.exportCalibrationDatasetCsv();
              SharePlus.instance.share(
                ShareParams(
                  text: csvData,
                  subject: 'SoilpHTxAI_Laboratory_Calibration_Dataset.csv',
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Partition statistics banner (70% / 15% / 15%)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
            child: GlassmorphicCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'การแบ่งส่วนข้อมูลตามระเบียบวิธีวิจัย (ขั้นตอนที่ 3.1)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('รวม 168 ตัวอย่าง', style: TextStyle(fontSize: 11, color: AppTheme.accentNeon)),
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
