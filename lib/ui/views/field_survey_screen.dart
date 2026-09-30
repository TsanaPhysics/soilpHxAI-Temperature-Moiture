import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/soil_data_point.dart';
import '../../core/utils/responsive.dart';
import '../../viewmodels/soil_pht_viewmodel.dart';
import '../widgets/glassmorphic_card.dart';

class FieldSurveyScreen extends StatelessWidget {
  const FieldSurveyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SoilPhtViewModel>(context);
    final samples = vm.fieldSamples;
    final padding = Responsive.horizontalPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('การสำรวจดินภาคสนาม & การจัดการปูน', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('พื้นที่วิจัย จันทบุรี - ตราด (30 ตัวอย่างดินมาตรฐาน)', style: TextStyle(fontSize: 11, color: AppTheme.primaryCyan)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'ส่งออกข้อมูลสำรวจภาคสนาม .CSV',
            icon: const Icon(Icons.share, color: AppTheme.primaryEmerald),
            onPressed: () {
              final csvData = vm.exportFieldSamplesCsv();
              SharePlus.instance.share(
                ShareParams(
                  text: csvData,
                  subject: 'SoilpHTxAI_Field_Durian_Soil_Survey.csv',
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Research Target Sites Selector
            const Text(
              'พื้นที่วิจัยเป้าหมายตามข้อเสนอโครงการ (ส่วนที่ 4.2 & 4.3)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan),
            ),
            const SizedBox(height: 8),
            _buildSitesHorizontalList(context, vm),
            const SizedBox(height: 12),

            // Active Site Overview
            _buildActiveSiteDetails(context, vm),
            const SizedBox(height: 12),

            // 30 Field Samples Header & Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'บันทึกผลการทดสอบตัวอย่างดิน (${samples.length} จุด)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryEmerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.3)),
                  ),
                  child: const Text('เปรียบเทียบ Lab มาตรฐาน', style: TextStyle(fontSize: 10, color: AppTheme.primaryEmerald)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Field Samples List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: samples.length,
              itemBuilder: (context, index) {
                final SoilDataPoint item = samples[index];
                return _buildSampleCard(context, item);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSitesHorizontalList(BuildContext context, SoilPhtViewModel vm) {
    final double cardWidth = min(240.0, MediaQuery.of(context).size.width * 0.72);

    return SizedBox(
      height: 95,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppConstants.targetSites.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final site = AppConstants.targetSites[idx];
          final bool isSelected = vm.selectedSiteIndex == idx;

          return GestureDetector(
            onTap: () => vm.selectTargetSite(idx),
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.surfaceCard : AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryEmerald : Colors.white12,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          site['village'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? AppTheme.primaryEmerald : AppTheme.neutralText),
                        ),
                      ),
                      Text(site['province'], style: const TextStyle(fontSize: 10, color: AppTheme.mutedText)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(site['subdistrict'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppTheme.mutedText)),
                  Text(site['crop'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: AppTheme.primaryCyan)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveSiteDetails(BuildContext context, SoilPhtViewModel vm) {
    final site = vm.currentTargetSite;

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'ข้อมูลพื้นที่: ${site['village']} ${site['subdistrict']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryEmerald),
                ),
              ),
              const Icon(Icons.location_on, size: 16, color: AppTheme.dangerRose),
            ],
          ),
          const SizedBox(height: 6),
          _buildInfoRow('พิกัดภูมิศาสตร์ (GPS):', '${site['lat'].toStringAsFixed(4)}° N, ${site['lng'].toStringAsFixed(4)}° E'),
          _buildInfoRow('ชนิดดินประจำถิ่น:', site['soilType']),
          _buildInfoRow('พืชเศรษฐกิจเป้าหมาย:', site['crop']),
          _buildInfoRow('ค่า pH เฉลี่ยในพื้นที่:', '${site['typicalPh']} (สภาพดินเป็นกรด)'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.mutedText)),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 4,
            child: Text(
              val,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.neutralText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleCard(BuildContext context, SoilDataPoint item) {
    final double? err = item.aiErrorFromLab;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(item.sampleId, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.siteName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'AI: ${item.aiPh.toStringAsFixed(2)} pH',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryEmerald),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text('Lab มาตรฐาน: ${item.labStandardPh?.toStringAsFixed(2) ?? "N/A"} pH', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppTheme.mutedText)),
                ),
                if (err != null)
                  Text(
                    'ความคลาดเคลื่อน: ±${err.toStringAsFixed(3)} pH',
                    style: const TextStyle(fontSize: 10, color: AppTheme.accentNeon, fontWeight: FontWeight.w600),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'คำแนะนำใส่ปูนโดโลไมต์:',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: AppTheme.mutedText),
                    ),
                  ),
                  const SizedBox(width: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.recommendedLimeKgPerRai > 0
                          ? '${item.recommendedLimeKgPerRai.toStringAsFixed(0)} กก./ไร่'
                          : 'ไม่ต้องใส่ปูน (pH เหมาะสม)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: item.recommendedLimeKgPerRai > 0 ? AppTheme.warningOrange : AppTheme.primaryEmerald,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
