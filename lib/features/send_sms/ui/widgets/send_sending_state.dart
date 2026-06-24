import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/send_sms/data/models/send_progress.dart';

class SendSendingState extends StatelessWidget {
  final SendProgress progress;
  final bool isPaused;

  const SendSendingState({
    super.key,
    required this.progress,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: progress.progressPercent,
                          strokeWidth: 10,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isPaused ? AppColors.warning : AppColors.primary,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(progress.progressPercent * 100).toInt()}%',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              isPaused ? 'متوقف' : 'جارٍ',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isPaused ? AppColors.warning : AppColors.primary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (progress.currentStudentName.isNotEmpty && !isPaused)
                  Text(
                    'يتم إرسال رسالة إلى: ${progress.currentStudentName}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textDirection: TextDirection.rtl,
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MiniStat(label: 'متبقي', value: '${progress.remaining}', color: AppColors.statOrange),
                    _MiniStat(label: 'فاشل', value: '${progress.failed}', color: AppColors.statRed),
                    _MiniStat(label: 'مرسل', value: '${progress.sent}', color: AppColors.statGreen),
                    _MiniStat(label: 'الإجمالي', value: '${progress.total}', color: AppColors.statBlue),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('السجل المباشر', style: Theme.of(context).textTheme.titleSmall, textDirection: TextDirection.rtl),
                      const SizedBox(width: 8),
                      const Icon(Icons.list_alt_rounded, size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: progress.recentLogs.length,
                    itemBuilder: (context, i) {
                      final log = progress.recentLogs[i];
                      return ListTile(
                        dense: true,
                        trailing: Icon(
                          log.success ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: log.success ? AppColors.success : AppColors.error,
                          size: 18,
                        ),
                        title: Text(log.studentName, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 13)),
                        subtitle: Text(log.phone, textDirection: TextDirection.ltr, style: const TextStyle(fontSize: 11)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
