import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../widgets/intro_slide.dart';

class IntroCarouselScreen extends StatelessWidget {
  const IntroCarouselScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const GradientBackground(
      child: Scaffold(
        body: SafeArea(
          child: _IntroContent(),
        ),
      ),
    );
  }
}

class _IntroContent extends StatefulWidget {
  const _IntroContent();

  @override
  State<_IntroContent> createState() => _IntroContentState();
}

class _IntroContentState extends State<_IntroContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'icon': '🧠',
      'title': 'What is RememberWell?',
      'subtitle': 'A memory training app that transforms your daily life events into structured memories and recall challenges.',
    },
    {
      'icon': '💪',
      'title': 'Why memory training?',
      'subtitle': 'Strengthen your episodic, contextual, and sensory memory with scientifically-backed spaced repetition.',
    },
    {
      'icon': '📝',
      'title': 'How it works',
      'subtitle': 'Log memories → Get quizzed → Track progress → Improve recall.',
    },
    {
      'icon': '🔒',
      'title': 'Privacy-first',
      'subtitle': 'All your data stays on your device. No cloud, no tracking, no social sharing.',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.preferencesSetup);
    }
  }

  void _skip() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.preferencesSetup);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return IntroSlide(
                icon: slide['icon']!,
                title: slide['title']!,
                subtitle: slide['subtitle']!,
              );
            },
          ),
        ),
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppColors.ctaPrimary
                    : AppColors.subtext.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Buttons
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              CustomButton(
                text: _currentPage == 3 ? 'Get Started' : 'Next',
                onPressed: _next,
                isExpanded: true,
                icon: Icons.arrow_forward_ios,
              ),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: _skip,
                child: const Text('Skip'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}