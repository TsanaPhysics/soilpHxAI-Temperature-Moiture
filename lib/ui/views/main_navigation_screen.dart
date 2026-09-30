import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/soil_pht_viewmodel.dart';
import 'live_monitor_screen.dart';
import 'dataset_screen.dart';
import 'hypothesis_screen.dart';
import 'field_survey_screen.dart';
import 'project_firmware_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    LiveMonitorScreen(),
    DatasetScreen(),
    HypothesisScreen(),
    FieldSurveyScreen(),
    ProjectFirmwareScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return;
    final vm = context.read<SoilPhtViewModel>();
    if (state == AppLifecycleState.resumed) {
      // Re-claim USB-C port automatically when app comes to foreground
      vm.connectUsb();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Release USB-C port gracefully so other soil apps can use it
      vm.disconnectUsb();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors_outlined),
            activeIcon: Icon(Icons.sensors),
            label: 'วัดค่าสด',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science_outlined),
            activeIcon: Icon(Icons.science),
            label: 'ชุดข้อมูล Lab',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'สมมติฐาน H₀',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.terrain_outlined),
            activeIcon: Icon(Icons.terrain),
            label: 'สำรวจดิน',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.memory_outlined),
            activeIcon: Icon(Icons.memory),
            label: 'ESP32 / ทุน',
          ),
        ],
      ),
    );
  }
}
