import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:sender_sms/core/constants/app_colors.dart';
import 'package:sender_sms/core/di/injection.dart';
import 'package:sender_sms/core/routing/app_routes.dart';
import 'package:sender_sms/core/services/hive_datasource.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      lottieAsset: 'assets/send.json',
      title: 'إرسال النتائج بسهولة',
      description:
          'أرسل نتائج الطلاب دفعة واحدة وبسرعة فائقة من خلال استيراد ملفات Excel مباشرة إلى التطبيق.',
    ),
    OnboardingSlide(
      lottieAsset: 'assets/SECURITY.json',
      title: 'حماية وخصوصية تامة',
      description:
          'بيانات الطلاب والنتائج محمية بأحدث تقنيات الأمان لضمان الخصوصية والسرية الكاملة.',
    ),
    OnboardingSlide(
      lottieAsset: 'assets/Notification Bell.json',
      title: 'تنبيهات وتقارير فورية',
      description:
          'تابع حالة الإرسال أولاً بأول واحصل على تقارير تفصيلية فورية لكل عملية إرسال.',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final hive = sl<HiveDatasource>();
    await hive.settingsData.put('onboarding_completed', true);
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'تخطي',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ),

            // Slider PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          slide.lottieAsset,
                          height: 280,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Next / Start Button
                  SizedBox(
                    height: 50,
                    width: 130,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentPage == _slides.length - 1
                            ? 'ابدأ الآن'
                            : 'التالي',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),

                  // Indicators
                  Row(
                    children: List.generate(_slides.length, (index) {
                      final isSelected = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8,
                        width: isSelected ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : const Color(0xFFE8EDF0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingSlide {
  final String lottieAsset;
  final String title;
  final String description;

  OnboardingSlide({
    required this.lottieAsset,
    required this.title,
    required this.description,
  });
}
