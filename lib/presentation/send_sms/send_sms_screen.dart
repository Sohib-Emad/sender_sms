import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/di/injection.dart';
import '../../core/router/app_router.dart';
import '../../domain/entities/student.dart';
import '../settings/bloc/settings_bloc.dart';
import '../settings/bloc/settings_event.dart';
import '../settings/bloc/settings_state.dart';
import 'bloc/send_bloc.dart';
import 'bloc/send_event.dart';
import 'bloc/send_state.dart';

class SendSmsScreen extends StatelessWidget {
  final List<Student> students;
  final String template;

  const SendSmsScreen({
    super.key,
    required this.students,
    required this.template,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<SendBloc>()),
        BlocProvider(
          create: (_) => sl<SettingsBloc>()..add(SettingsLoad()),
        ),
      ],
      child: _SendSmsBody(students: students, template: template),
    );
  }
}

class _SendSmsBody extends StatelessWidget {
  final List<Student> students;
  final String template;

  const _SendSmsBody({required this.students, required this.template});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final state = context.read<SendBloc>().state;
        if (state is SendInProgress) {
          final confirm = await _showCancelConfirm(context);
          if (confirm) {
            context.read<SendBloc>().add(SendCancel());
            return true;
          }
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.sendSms),
          automaticallyImplyLeading: false,
          leading: BlocBuilder<SendBloc, SendState>(
            builder: (context, state) {
              if (state is SendInProgress || state is SendPaused) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => context.pop(),
              );
            },
          ),
        ),
        body: BlocConsumer<SendBloc, SendState>(
          listener: (context, state) {
            if (state is SendCompleted) {
              context.pushReplacement(
                AppRouter.results,
                extra: {
                  'sessionId': state.progress.sessionId,
                  'total': state.progress.total,
                  'sent': state.progress.sent,
                  'failed': state.progress.failed,
                },
              );
            }
            if (state is SendPermissionDenied) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.permissionDenied,
                      textDirection: TextDirection.rtl),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(child: _buildContent(context, state)),
                    _buildControls(context, state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SendState state) {
    if (state is SendIdle || state is SendRequestingPermission) {
      return _buildReadyState(context, state);
    }

    if (state is SendPermissionDenied) {
      return _buildPermissionError(context);
    }

    if (state is SendInProgress || state is SendPaused) {
      final progress = state is SendInProgress
          ? state.progress
          : (state as SendPaused).progress;
      return _buildSendingState(context, progress,
          isPaused: state is SendPaused);
    }

    if (state is SendCancelled) {
      return _buildCancelledState(context, state.progress);
    }

    return const SizedBox.shrink();
  }

  Widget _buildReadyState(BuildContext context, SendState state) {
    return Column(
      children: [
        // Summary card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(Icons.send_rounded, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                'جاهز للإرسال',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${students.length} رسالة ستُرسل',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white70),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ).animate().scale(duration: 400.ms).fadeIn(),

        const SizedBox(height: 20),

        // Template preview
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('معاينة الرسالة',
                        style: Theme.of(context).textTheme.titleMedium,
                        textDirection: TextDirection.rtl),
                    const SizedBox(width: 8),
                    const Icon(Icons.preview_rounded,
                        size: 18, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  students.isNotEmpty
                      ? template
                          .replaceAll('{name}', students.first.name)
                          .replaceAll('{degree}', students.first.degree)
                          .replaceAll('{phone}', students.first.phone)
                      : template,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 200.ms).fadeIn(),

        if (state is SendRequestingPermission)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text(AppStrings.requestingPermissions,
                    textDirection: TextDirection.rtl),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSendingState(BuildContext context, dynamic progress,
      {required bool isPaused}) {
    return Column(
      children: [
        // Main progress card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Circular progress
                SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: progress.progressPercent,
                        strokeWidth: 10,
                        backgroundColor: AppColors.darkDivider,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isPaused ? AppColors.warning : AppColors.primary,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(progress.progressPercent * 100).toInt()}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              isPaused ? 'متوقف' : 'جارٍ',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isPaused
                                        ? AppColors.warning
                                        : AppColors.primary,
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

                // Stats row
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
        ),

        const SizedBox(height: 16),

        // Live log
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
                      Text('السجل المباشر',
                          style: Theme.of(context).textTheme.titleSmall,
                          textDirection: TextDirection.rtl),
                      const SizedBox(width: 8),
                      const Icon(Icons.list_alt_rounded,
                          size: 16, color: AppColors.primary),
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
                          log.success
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color:
                              log.success ? AppColors.success : AppColors.error,
                          size: 18,
                        ),
                        title: Text(
                          log.studentName,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(fontSize: 13),
                        ),
                        subtitle: Text(
                          log.phone,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(fontSize: 11),
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

  Widget _buildCancelledState(BuildContext context, dynamic progress) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cancel_rounded,
              size: 80, color: AppColors.warning),
          const SizedBox(height: 16),
          const Text('تم إلغاء الإرسال',
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'تم إرسال ${progress.sent} من ${progress.total}',
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionError(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_rounded, size: 80, color: AppColors.error),
          const SizedBox(height: 16),
          const Text(AppStrings.permissionDenied,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(AppStrings.permissionRequired,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context, SendState state) {
    if (state is SendIdle || state is SendRequestingPermission) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: state is SendRequestingPermission
                  ? null
                  : () {
                      final settings =
                          (context.read<SettingsBloc>().state as SettingsLoaded?)
                              ?.settings;
                      context.read<SendBloc>().add(SendStartBatch(
                            students: students,
                            template: template,
                            settings: settings!,
                          ));
                    },
              icon: const Icon(Icons.send_rounded),
              label: Text(
                  '${AppStrings.startSending} (${students.length})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (state is SendInProgress) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showCancelConfirm(context).then((confirm) {
                if (confirm) context.read<SendBloc>().add(SendCancel());
              }),
              icon: const Icon(Icons.stop_rounded, color: AppColors.error),
              label: const Text(AppStrings.cancelSending,
                  style: TextStyle(color: AppColors.error)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () =>
                  context.read<SendBloc>().add(SendPause()),
              icon: const Icon(Icons.pause_rounded),
              label: const Text(AppStrings.pauseSending),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning),
            ),
          ),
        ],
      );
    }

    if (state is SendPaused) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showCancelConfirm(context).then((confirm) {
                // ignore: use_build_context_synchronously
                if (confirm) context.read<SendBloc>().add(SendCancel());
              }),
              icon: const Icon(Icons.stop_rounded, color: AppColors.error),
              label: const Text(AppStrings.cancelSending,
                  style: TextStyle(color: AppColors.error)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () =>
                  context.read<SendBloc>().add(SendResume()),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(AppStrings.resumeSending),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success),
            ),
          ),
        ],
      );
    }

    if (state is SendCancelled) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: () {
            context.read<SendBloc>().add(SendReset());
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('العودة'),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<bool> _showCancelConfirm(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('إلغاء الإرسال',
                textDirection: TextDirection.rtl),
            content: const Text(AppStrings.confirmCancel,
                textDirection: TextDirection.rtl),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(AppStrings.no),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error),
                child: const Text(AppStrings.yes,
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;
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
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
