import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/constants/screen_strings.dart';
import 'package:sender_sms/core/utils/extensions.dart';
import 'package:sender_sms/features/home/logic/home_cubit.dart';
import 'stat_card.dart';

class HomeStatsSection extends StatelessWidget {
  final HomeState state;
  const HomeStatsSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    int students = 0, sent = 0, failed = 0;
    String lastSession = 'لا يوجد';

    if (state is HomeLoaded) {
      final s = state as HomeLoaded;
      students = s.totalStudents;
      sent = s.totalSent;
      failed = s.totalFailed;
      lastSession = s.lastSession?.date.relativeTime ?? 'لا يوجد';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'الإحصائيات',
          style: Theme.of(context).textTheme.titleLarge,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: ScreenStrings.messagesFailed,
                value: failed.withCommas(),
                icon: Icons.cancel_rounded,
                color: AppColors.statRed,
                delay: 300,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: ScreenStrings.messagesSent,
                value: sent.withCommas(),
                icon: Icons.check_circle_rounded,
                color: AppColors.statGreen,
                delay: 200,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: ScreenStrings.lastSession,
                value: lastSession,
                icon: Icons.access_time_rounded,
                color: AppColors.statOrange,
                delay: 400,
                isSmallText: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: ScreenStrings.totalStudents,
                value: students.withCommas(),
                icon: Icons.people_rounded,
                color: AppColors.statBlue,
                delay: 100,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
