import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sender_sms/features/home/ui/home_page.dart';
import 'package:sender_sms/features/inbox/ui/inbox_page.dart';
import 'package:sender_sms/features/history/ui/history_page.dart';
import 'package:sender_sms/features/manual_sms/ui/manual_sms_page.dart';
import 'package:sender_sms/features/settings/ui/settings_page.dart';
import 'package:sender_sms/features/auth/ui/widgets/phone_confirmation_dialog.dart';
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

  @override
  void initState() {
    super.initState();
    _requestAllPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PhoneConfirmationDialog.show(context);
    });
  }

  Future<void> _requestAllPermissions() async {
    await [
      Permission.sms,
      Permission.phone,
      Permission.notification,
    ].request();
  }

  void setTab(int index) {
    if (index >= 0 && index < 5) {
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
          InboxPage(isTab: true),
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

