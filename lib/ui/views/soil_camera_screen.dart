import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/soil_pht_viewmodel.dart';

class SoilCameraScreen extends StatefulWidget {
  const SoilCameraScreen({super.key});

  @override
  State<SoilCameraScreen> createState() => _SoilCameraScreenState();
}

class _SoilCameraScreenState extends State<SoilCameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isInitialized = false;
  bool _isCapturing = false;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      _selectedCameraIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;

      await _setupController(_cameras[_selectedCameraIndex]);
    } catch (e) {
      debugPrint('[SoilCameraScreen] Camera error: $e');
    }
  }

  Future<void> _setupController(CameraDescription camera) async {
    await _controller?.dispose();
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      await controller.setFlashMode(_flashMode);
      if (mounted) {
        setState(() {
          _controller = controller;
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('[SoilCameraScreen] Controller init error: $e');
    }
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    FlashMode nextMode;
    switch (_flashMode) {
      case FlashMode.off:
        nextMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        nextMode = FlashMode.auto;
        break;
      case FlashMode.auto:
      default:
        nextMode = FlashMode.off;
        break;
    }
    await _controller!.setFlashMode(nextMode);
    setState(() => _flashMode = nextMode);
  }

  Future<void> _takeSoilPhoto(SoilPhtViewModel vm) async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) return;

    setState(() => _isCapturing = true);
    try {
      final XFile photo = await _controller!.takePicture();
      final Directory docDir = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String savedPath = '${docDir.path}/soil_photo_$timestamp.jpg';

      await File(photo.path).copy(savedPath);

      if (mounted) {
        _showSuccessDialog(context, vm, savedPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.dangerRose,
            content: Text('ถ่ายภาพไม่สำเร็จ: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _showSuccessDialog(BuildContext context, SoilPhtViewModel vm, String filePath) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppTheme.primaryEmerald),
            SizedBox(width: 8),
            Text('บันทึกภาพตัวอย่างดินสำเร็จ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(filePath),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text('แปลงศึกษา: ${vm.currentTargetSite['village']} (${vm.currentTargetSite['province']})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.neutralText)),
            Text('พิกัด GPS: ${vm.liveLatitude?.toStringAsFixed(6) ?? vm.currentTargetSite['lat']}, ${vm.liveLongitude?.toStringAsFixed(6) ?? vm.currentTargetSite['lng']}',
                style: const TextStyle(fontSize: 11, color: AppTheme.primaryCyan)),
            const SizedBox(height: 4),
            Text('pH ที่วัดได้: ${vm.displayedPh.toStringAsFixed(2)} pH | ${vm.potentialMv.toStringAsFixed(1)} mV | ${vm.temperatureC.toStringAsFixed(1)} °C',
                style: const TextStyle(fontSize: 11, color: AppTheme.accentNeon)),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.share, size: 18, color: AppTheme.primaryCyan),
            label: const Text('แชร์ภาพ', style: TextStyle(color: AppTheme.primaryCyan)),
            onPressed: () {
              Navigator.pop(context);
              SharePlus.instance.share(
                ShareParams(
                  text: 'ภาพตัวอย่างดินวิจัย SoilpHTxAI: pH ${vm.displayedPh.toStringAsFixed(2)} ที่ ${vm.currentTargetSite['village']}',
                  files: [XFile(filePath)],
                ),
              );
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryEmerald,
              foregroundColor: Colors.black,
            ),
            child: const Text('ตกลง'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SoilPhtViewModel>(context);

    if (!_isInitialized || _controller == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('กล้องบันทึกภาพดิน (Soil Vision)')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryEmerald),
              SizedBox(height: 16),
              Text('กำลังเปิดกล้องสมาร์ทโฟน...', style: TextStyle(color: AppTheme.mutedText)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Live Camera Preview
          CameraPreview(_controller!),

          // Target Crosshair / Reticle for Soil Probe Tip
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.accentNeon.withValues(alpha: 0.7), width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentNeon,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 6,
                    left: 0,
                    right: 0,
                    child: Text(
                      'จัดกึ่งกลางตัวอย่างดิน',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 9, color: AppTheme.accentNeon, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Overlay Bar (Controls & Geotags)
          Positioned(
            top: 40,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${vm.currentTargetSite['village']} (${vm.currentTargetSite['province']})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'GPS: ${vm.liveLatitude?.toStringAsFixed(5) ?? vm.currentTargetSite['lat']}, ${vm.liveLongitude?.toStringAsFixed(5) ?? vm.currentTargetSite['lng']}',
                          style: const TextStyle(fontSize: 10, color: AppTheme.primaryCyan),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _flashMode == FlashMode.torch ? Icons.flash_on : Icons.flash_off,
                      color: _flashMode == FlashMode.torch ? AppTheme.warningOrange : Colors.white,
                    ),
                    onPressed: _toggleFlash,
                  ),
                  if (_cameras.length > 1)
                    IconButton(
                      icon: const Icon(Icons.flip_camera_android, color: Colors.white),
                      onPressed: _toggleCamera,
                    ),
                ],
              ),
            ),
          ),

          // Bottom Overlay Bar (Telemetry Badge & Shutter Button)
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Live Soil Parameter Telemetry Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryEmerald.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniParam('pH วัดได้', '${vm.displayedPh.toStringAsFixed(2)} pH', AppTheme.accentNeon),
                      _buildMiniParam('ศักย์ E', '${vm.potentialMv.toStringAsFixed(1)} mV', AppTheme.primaryCyan),
                      _buildMiniParam('อุณหภูมิ T', '${vm.temperatureC.toStringAsFixed(1)} °C', AppTheme.warningOrange),
                      _buildMiniParam('ความชื้น', '${vm.usbMoisture.toStringAsFixed(1)} %', AppTheme.infoBlue),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Big Capture Button
                GestureDetector(
                  onTap: _isCapturing ? null : () => _takeSoilPhoto(vm),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: _isCapturing ? Colors.grey : AppTheme.primaryEmerald,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryEmerald.withValues(alpha: 0.5),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: _isCapturing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.camera_alt, color: Colors.black, size: 34),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'แตะเพื่อบันทึกภาพหลักฐานตัวอย่างดิน',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniParam(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.mutedText)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
