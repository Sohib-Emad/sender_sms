import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/manual_sms_form.dart';

class ManualSmsPage extends StatelessWidget {
  final bool isTab;
  const ManualSmsPage({super.key, this.isTab = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إرسال يدوي'),
        automaticallyImplyLeading: !isTab,
        leading: isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => context.pop(),
              ),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: ManualSmsForm(),
        ),
      ),
    );
  }
}
