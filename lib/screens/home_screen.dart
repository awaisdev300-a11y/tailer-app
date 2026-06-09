// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/measurements_tab.dart'; // <--- We will create this next
import 'tabs/khata_tab.dart';
import 'tabs/settings_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // The 4 Tabs in Correct Order
  final List<Widget> _tabs = [
    const DashboardTab(), // 0: Home
    const MeasurementsTab(), // 1: Sizes (Customer List)
    const KhataTab(), // 2: Khata
    const SettingsTab(), // 3: Settings/Profile
  ];

  @override
  Widget build(BuildContext context) {
    final Color darkSlate = Theme.of(context).primaryColor;

    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
          child: GNav(
            backgroundColor: Colors.white,
            color: Colors.grey,
            activeColor: Colors.white,
            tabBackgroundColor: darkSlate,
            gap: 8,
            padding: const EdgeInsets.all(16),
            tabs: const [
              GButton(icon: Icons.home_filled, text: 'Home'),
              GButton(icon: Icons.straighten, text: 'Sizes'),
              GButton(icon: Icons.account_balance_wallet, text: 'Khata'),
              GButton(icon: Icons.settings, text: 'Settings'),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
