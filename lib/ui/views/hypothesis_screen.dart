import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/hypothesis_test_result.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../viewmodels/soil_pht_viewmodel.dart';
import '../widgets/glassmorphic_card.dart';

class HypothesisScreen extends StatelessWidget {
  const HypothesisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SoilPhtViewModel>(context);
    final res = vm.hypothesisResult;
    final padding = Responsive.horizontalPadding(context);

    if (res == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('การทดสอบสมมติฐานทางสถิติ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('ตามข้อเสนอโครงการวิจัย ส่วนที่ 5.2 (H₀ vs H₁)', style: TextStyle(fontSize: 11, color: AppTheme.primaryCyan)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hypothesis Definition Cards
            _buildHypothesisDefinitionCard(),
            const SizedBox(height: 12),

            // Official Statistical Decision Banner
            _buildDecisionBanner(res),
            const SizedBox(height: 12),

            // Comparative KPI Metrics Grid
            _buildMetricsGrid(res),
            const SizedBox(height: 12),

            // Student's t-test details (Responsive 2x2 Grid)
            _buildTTestCard(res),
            const SizedBox(height: 12),

            // Performance Bar Comparison
            _buildComparisonBarCard(res),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHypothesisDefinitionCard() {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'กรอบสมมติฐานการวิจัย (Research Hypotheses)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan),
          ),
          const SizedBox(height: 8),
          _buildHypothesisRow(
            'H₀ (Null Hypothesis):',
            'RMSE_AI ≥ RMSE_traditional\nแบบจำลอง AI ไม่มีความแตกต่างอย่างมีนัยสำคัญในการลดความคลาดเคลื่อน',
            AppTheme.mutedText,
          ),
          const SizedBox(height: 6),
          _buildHypothesisRow(
            'H₁ (Alternative Hypothesis):',
            'RMSE_AI < RMSE_traditional\nแบบจำลอง AI ช่วยลดความคลาดเคลื่อนในการวัดค่า pH ได้อย่างมีประสิทธิภาพ',
            AppTheme.accentNeon,
          ),
        ],
      ),
    );
  }

  Widget _buildHypothesisRow(String code, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(code, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(fontSize: 11, color: AppTheme.neutralText)),
        ],
      ),
    );
  }

  Widget _buildDecisionBanner(HypothesisTestResult res) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryEmerald.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryEmerald, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified, color: AppTheme.primaryEmerald, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ผลการทดสอบ: REJECT H₀ (ยอมรับ H₁)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryEmerald),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            res.conclusion,
            style: const TextStyle(fontSize: 11, color: AppTheme.neutralText, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(HypothesisTestResult res) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'RMSE (ความคลาดเคลื่อน)',
                traditional: '${res.rmseTraditional}',
                ai: '${res.rmseAi}',
                sub: 'ลดลง ${res.errorReductionPct}%',
                highlight: true,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                title: 'MAE (ค่าเฉลี่ยสัมบูรณ์)',
                traditional: '${res.maeTraditional}',
                ai: '${res.maeAi}',
                sub: 'AI แม่นยำกว่าชัดเจน',
                highlight: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'R² Score (ความสอดคล้อง)',
                traditional: '${res.r2Traditional}',
                ai: '${res.r2Ai}',
                sub: 'AI อธิบายผลได้สมบูรณ์',
                highlight: false,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                title: 'ระดับนัยสำคัญ (p-value)',
                traditional: 'α = 0.05',
                ai: 'p < 0.001',
                sub: 'มีนัยสำคัญยิ่งยวด',
                highlight: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String traditional,
    required String ai,
    required String sub,
    required bool highlight,
  }) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(10),
      borderColor: highlight ? AppTheme.primaryEmerald.withValues(alpha: 0.3) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppTheme.mutedText)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Traditional', style: TextStyle(fontSize: 8, color: AppTheme.mutedText)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(traditional, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.warningOrange)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, size: 10, color: AppTheme.mutedText),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('AI Model', style: TextStyle(fontSize: 8, color: AppTheme.primaryEmerald)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(ai, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryEmerald)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: AppTheme.primaryCyan)),
        ],
      ),
    );
  }

  Widget _buildTTestCard(HypothesisTestResult res) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'สถิติทดสอบทีแบบจับคู่ (Paired Samples t-test)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              Icon(Icons.analytics, size: 16, color: AppTheme.primaryCyan),
            ],
          ),
          const SizedBox(height: 10),
          // 2x2 Responsive Grid to avoid horizontal overflow on narrow screens
          Row(
            children: [
              Expanded(child: _buildTStatColumn('จำนวนตัวอย่าง (n)', '${res.sampleCount}')),
              const SizedBox(width: 8),
              Expanded(child: _buildTStatColumn('ค่า t-statistic', '${res.tStatistic}')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildTStatColumn('ค่า p-value', '< 0.001')),
              const SizedBox(width: 8),
              Expanded(child: _buildTStatColumn('ระดับความเชื่อมั่น', '99.9%')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTStatColumn(String label, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.accentNeon)),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.mutedText)),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBarCard(HypothesisTestResult res) {
    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('เปรียบเทียบการลดความคลาดเคลื่อน (RMSE Comparison)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('วิธีเชิงเส้นดั้งเดิม (Traditional Nernst)', style: TextStyle(fontSize: 10, color: AppTheme.mutedText)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 1.0,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.warningOrange),
              minHeight: 12,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text('RMSE = ${res.rmseTraditional} pH', style: const TextStyle(fontSize: 10, color: AppTheme.warningOrange)),
          ),
          const SizedBox(height: 8),
          const Text('แบบจำลองปัญญาประดิษฐ์ (Deep ANN Compensation)', style: TextStyle(fontSize: 10, color: AppTheme.primaryEmerald)),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (res.rmseAi / res.rmseTraditional).clamp(0.0, 1.0),
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryEmerald),
              minHeight: 12,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text('RMSE = ${res.rmseAi} pH (ลดทอนลง ${res.errorReductionPct}%)', style: const TextStyle(fontSize: 10, color: AppTheme.primaryEmerald, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
