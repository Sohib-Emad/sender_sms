import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sender_sms/core/routing/app_routes.dart';
import 'package:sender_sms/features/auth/logic/auth_cubit.dart';
import 'package:sender_sms/features/auth/logic/auth_state.dart';
import 'package:sender_sms/features/home/logic/home_cubit.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/default_sms_banner.dart';
import 'widgets/home_stats_section.dart';
import 'widgets/home_actions_section.dart';
import 'widgets/home_recent_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated && authState.user.isAdmin) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go(AppRoutes.adminDashboard);
            }
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          body: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return CustomScrollView(
                slivers: [
                  const HomeAppBar(),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const DefaultSmsBanner(),
                        const HomeActionsSection(),
                        const SizedBox(height: 24),
                        HomeStatsSection(state: state),
                        const SizedBox(height: 24),
                        HomeRecentSection(state: state),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
