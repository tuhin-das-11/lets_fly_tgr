import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../routing/route_names.dart';
import '../../../../shared/widgets/app_button.dart';

class OnboardingItem {
  final String title;
  final String subtitle;
  final String assetPath;

  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.assetPath,
  });
}

/// 3-slide interactive onboarding experience highlighting key value propositions.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingItem> _pages = [
    OnboardingItem(
      title: 'Study Together',
      subtitle:
          'Join virtual study rooms and stay accountable with peer visibility and live group sessions.',
      assetPath: AppAssets.onboardingDesk,
    ),
    OnboardingItem(
      title: 'Focus Better',
      subtitle:
          'Shield against digital distractions with proactive app blocking and server-synced timers across Android and Windows.',
      assetPath: AppAssets.icFocusMode,
    ),
    OnboardingItem(
      title: 'Fly Higher',
      subtitle:
          'Gain deep productivity insights, track daily streaks, and accelerate learning with AI note syntheses.',
      assetPath: AppAssets.logo,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyHasCompletedOnboarding, true);
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.insetScreen,
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text('Skip', style: AppTypography.labelLarge),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              item.assetPath,
                              width: index == 0 ? 190 : 130,
                              height: index == 0 ? 150 : 130,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.flight_takeoff_rounded,
                                  size: 64,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.space40),
                          Text(
                            item.title,
                            style: AppTypography.headlineMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.space16),
                          Text(
                            item.subtitle,
                            style: AppTypography.bodyLarge.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.space32),
              AppButton(
                text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                onPressed: () {
                  if (_currentPage == _pages.length - 1) {
                    _completeOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
