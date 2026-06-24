import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sender_sms/core/constants/app_colors.dart';

class ResultsIndicator extends StatelessWidget {
  final double successRate;
  final bool isFullSuccess;

  const ResultsIndicator({
    super.key,
    required this.successRate,
    required this.isFullSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isFullSuccess ? AppColors.successGradient : AppColors.primaryGradient,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            isFullSuccess ? Icons.check_circle_rounded : Icons.done_all_rounded,
            color: Colors.white,
            size: 64,
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut).fadeIn(),
          const SizedBox(height: 16),
          const Text(
            'اكتملت عملية الإرسال',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: successRate / 100,
                  strokeWidth: 10,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${successRate.toInt()}%',
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'نسبة النجاح',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().scale(duration: 500.ms, delay: 300.ms).fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}
