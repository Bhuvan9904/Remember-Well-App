import 'package:flutter/material.dart';
import 'data/services/hive_service.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/main_navigation.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_colors.dart';
import 'shared/widgets/gradient_background.dart';
import 'features/onboarding/screens/intro_carousel_screen.dart';
import 'features/onboarding/screens/preferences_setup_screen.dart';
import 'features/memory/screens/new_memory_screen.dart';
import 'features/recall/screens/recall_queue_screen.dart';
import 'features/recall/screens/recall_quiz_screen.dart';
import 'data/repositories/preferences_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveService.init();
  
  runApp(const RememberWellApp());
}

class RememberWellApp extends StatelessWidget {
  const RememberWellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RememberWell',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.intro: (context) => const IntroCarouselScreen(),
        AppRoutes.preferencesSetup: (context) => const PreferencesSetupScreen(),
        AppRoutes.home: (context) => const MainNavigation(),
        AppRoutes.newMemory: (context) => const NewMemoryScreen(),
        AppRoutes.recallQueue: (context) => const RecallQueueScreen(),
        AppRoutes.recallQuiz: (context) => const RecallQuizScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    ));

    // Start animation
    _controller.forward();

    // Check onboarding status and route accordingly
    Future.delayed(const Duration(seconds: 2), () async {
      final prefsRepo = PreferencesRepository();
      final prefs = prefsRepo.get();
      
      if (!mounted) return;
      
      if (prefs.onboardingDone) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.intro);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Icon Container
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.ctaSecondary,
                                  AppColors.ctaPrimary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.ctaSecondary.withOpacity(0.5),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                                BoxShadow(
                                  color: AppColors.ctaPrimary.withOpacity(0.3),
                                  blurRadius: 60,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 80,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                
                // App Name with fade animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'RememberWell',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Tagline with fade animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Train Your Real-Life Memory',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.subtext,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                
                // Loading indicator
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
