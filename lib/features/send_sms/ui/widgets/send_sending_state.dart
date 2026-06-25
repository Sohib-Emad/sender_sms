import 'package:flutter/material.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/features/send_sms/data/models/send_progress.dart';

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color strokeColor;
  final Color trackColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.strokeColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Draw active progress arc
    final progressPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.1415926535 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1415926535 / 2, // Start at the top (-90 degrees)
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

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
    final percent = progress.progressPercent;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8EDF0), width: 0.5),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Custom Painted Circular Progress Indicator
              Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: CircularProgressPainter(
                            progress: percent,
                            strokeColor: AppColors.primary,
                            trackColor: const Color(0xFFE8EDF0),
                            strokeWidth: 10,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${(percent * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            isPaused ? 'متوقف' : 'جارٍ الإرسال',
                            style: TextStyle(
                              fontSize: 11,
                              color: isPaused
                                  ? AppColors.warning
                                  : AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (progress.currentStudentName.isNotEmpty && !isPaused) ...[
                Text(
                  'يتم إرسال رسالة إلى: ${progress.currentStudentName}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              // 4-column mini stats row: Total / Sent / Failed / Remaining with colored numbers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MiniStat(
                      label: 'متبقي',
                      value: '${progress.remaining}',
                      color: AppColors.statOrange),
                  _MiniStat(
                      label: 'فاشل',
                      value: '${progress.failed}',
                      color: AppColors.statRed),
                  _MiniStat(
                      label: 'مرسل',
                      value: '${progress.sent}',
                      color: AppColors.statGreen),
                  _MiniStat(
                      label: 'الإجمالي',
                      value: '${progress.total}',
                      color: AppColors.statBlue),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Live log card: list of sent/failed
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8EDF0), width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'السجل المباشر',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.list_alt_rounded,
                          size: 16, color: AppColors.primary),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE8EDF0)),
                Expanded(
                  child: ListView.separated(
                    reverse: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: progress.recentLogs.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFF8F9FA)),
                    itemBuilder: (context, i) {
                      final log = progress.recentLogs[i];
                      return ListTile(
                        dense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        leading: Icon(
                          log.success
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color:
                              log.success ? AppColors.primary : AppColors.error,
                          size: 18,
                        ),
                        title: Text(
                          log.studentName,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          log.phone,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
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

  const _MiniStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
