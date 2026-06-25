import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sender_sms/features/home/ui/main_layout_page.dart';
import 'featured_action_card.dart';
import 'timeline_action_tile.dart';

class HomeActionsSection extends StatelessWidget {
  const HomeActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const FeaturedActionCard(),
        const SizedBox(height: 24),
        Text(
          'عمليات سريعة',
          style: Theme.of(context).textTheme.titleLarge,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 16),
        TimelineActionTile(
          title: 'إرسال يدوي / سريع',
          subtitle: 'إرسال رسالة سريعة لرقم محدد مباشرة',
          icon: Icons.sms_rounded,
          onTap: () => MainLayoutPage.of(context)?.setTab(3),
          isActive: true,
          isLast: false,
        ),
        TimelineActionTile(
          title: 'سجل الإرسال والعمليات',
          subtitle: 'مراجعة حالة الإرسال للتقارير السابقة',
          icon: Icons.history_rounded,
          onTap: () => MainLayoutPage.of(context)?.setTab(2),
          isActive: false,
          isLast: true,
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOutQuad);
  }
}
