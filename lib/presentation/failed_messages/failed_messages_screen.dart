import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/sms_log.dart';
import '../../domain/usecases/get_sessions_usecase.dart';

class FailedMessagesScreen extends StatefulWidget {
  final String sessionId;
  const FailedMessagesScreen({super.key, required this.sessionId});

  @override
  State<FailedMessagesScreen> createState() => _FailedMessagesScreenState();
}

class _FailedMessagesScreenState extends State<FailedMessagesScreen> {
  List<SmsLog>? _failedLogs;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFailed();
  }

  Future<void> _loadFailed() async {
    final useCase = sl<GetFailedLogsUseCase>();
    final logs = await useCase(widget.sessionId);
    setState(() {
      _failedLogs = logs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.failedMessages),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_failedLogs != null && _failedLogs!.isNotEmpty)
            TextButton.icon(
              onPressed: _retryAll,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text(AppStrings.retryAll),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _failedLogs == null || _failedLogs!.isEmpty
              ? _buildEmpty()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _failedLogs!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final log = _failedLogs![i];
                    return _FailedLogCard(
                      log: log,
                      onRetry: () => _retrySingle(log),
                    );
                  },
                ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded,
              size: 64, color: AppColors.success),
          SizedBox(height: 16),
          Text(
            AppStrings.noFailed,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  void _retryAll() {
    // TODO: implement retry all - navigate to send screen with failed list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جارٍ إعداد إعادة الإرسال...',
            textDirection: TextDirection.rtl),
      ),
    );
  }

  void _retrySingle(SmsLog log) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('إعادة إرسال إلى ${log.studentName}...',
            textDirection: TextDirection.rtl),
      ),
    );
  }
}

class _FailedLogCard extends StatelessWidget {
  final SmsLog log;
  final VoidCallback onRetry;

  const _FailedLogCard({required this.log, required this.onRetry});

  String get _errorLabel {
    final error = log.errorMessage ?? '';
    if (error.contains('رصيد') || error.toLowerCase().contains('balance')) {
      return 'رصيد غير كافٍ';
    } else if (error.contains('رقم') || error.toLowerCase().contains('invalid')) {
      return 'رقم غير صحيح';
    } else if (error.toLowerCase().contains('network')) {
      return 'مشكلة في الشبكة';
    } else if (error.isEmpty) {
      return 'فشل النظام';
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      log.studentName,
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      log.phone,
                      style: Theme.of(context).textTheme.bodySmall,
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cancel_rounded,
                      color: AppColors.error, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _errorLabel,
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(width: 6),
                  const Text(AppStrings.failReason,
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
