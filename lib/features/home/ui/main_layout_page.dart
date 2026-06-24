import 'package:flutter/material.dart';
import 'package:sender_sms/features/home/ui/home_page.dart';
import 'package:sender_sms/features/history/ui/history_page.dart';
import 'package:sender_sms/features/manual_sms/ui/manual_sms_page.dart';
import 'package:sender_sms/features/settings/ui/settings_page.dart';
import 'widgets/custom_bottom_nav_bar.dart';

class MainLayoutPage extends StatefulWidget {
  const MainLayoutPage({super.key});

  static _MainLayoutPageState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainLayoutPageState>();
  }

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  int _currentIndex = 0;

  void setTab(int index) {
    if (index >= 0 && index < 4) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomePage(),
          HistoryPage(isTab: true),
          ManualSmsPage(isTab: true),
          SettingsPage(isTab: true),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: setTab,
      ),
    );
  }
}
