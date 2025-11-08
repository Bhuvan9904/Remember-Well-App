import 'package:flutter/material.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/recall/screens/recall_hub_screen.dart';
import '../../features/vault/screens/vault_screen.dart';
import '../../features/progress/screens/progress_dashboard_screen.dart';
import '../../features/settings/screens/settings_main_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    RecallHubScreen(),
    VaultScreen(),
    ProgressDashboardScreen(),
    SettingsMainScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8B6FB8), // blue
              Color(0xFFA98BC6), // light lavender/white mix
              Color(0xFFB599D4), // pinkish purple
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology),
              label: 'Recall',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: 'Vault',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
