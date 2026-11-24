import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants.dart';
import '../../core/widgets/rise_in.dart';
import '../../core/widgets/sparkle.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.auto_awesome,
      title: 'Welcome to Seer School',
      body:
          'An interactive study companion for the 78 cards of the Rider-Waite-Smith tarot deck.',
    ),
    _OnboardingPage(
      icon: Icons.school_rounded,
      title: 'Learn by Doing',
      body:
          'Draw a card and guess its element, suit, numerology, and theme. Elements are shown as alchemical symbols — suits as thematic keyword groups.',
    ),
    _OnboardingPage(
      icon: Icons.insights_rounded,
      title: 'Track Your Progress',
      body:
          'Every attempt is recorded. See which cards and categories you have mastered — and which need more practice.',
    ),
  ];

  void _complete() async {
    final box = await Hive.openBox('app_settings');
    await box.put('onboarding_complete', true);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _pages[i],
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final isCurrent = _currentPage == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    switchInCurve: twirlCurve,
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: isCurrent
                        ? const TwinklingSparkle(
                            key: ValueKey('current'),
                            size: 16,
                          )
                        : const SizedBox.square(
                            key: ValueKey('other'),
                            dimension: 16,
                            child: Sparkle(size: 9, color: AppColors.border),
                          ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _currentPage == _pages.length - 1
                      ? _complete
                      : () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Begin'
                        : 'Next',
                  ),
                ),
              ),
            ),

            if (_currentPage < _pages.length - 1)
              TextButton(
                onPressed: _complete,
                child: Text(
                  'Skip',
                  style: TextStyle(color: AppColors.muted),
                ),
              )
            else
              const SizedBox(height: 48),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RiseIn(child: Icon(icon, size: 72, color: AppColors.lilac)),
          const SizedBox(height: 32),
          RiseIn(
            delay: const Duration(milliseconds: 150),
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          RiseIn(
            delay: const Duration(milliseconds: 300),
            child: Text(
              body,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.muted,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
