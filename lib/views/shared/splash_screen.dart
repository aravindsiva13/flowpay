import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animations/animations.dart';
import '../../core/constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _progressAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    
    _logoRotateAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeInOut,
      ),
    );

    // Progress animations
    _progressController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAnimations() async {
    // Start logo animation
    _logoController.forward();
    
    // Start text animation after a delay
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      _textController.forward();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue,
              AppColors.primaryBlueDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with animations
                                              AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Transform.rotate(
                              angle: _logoRotateAnimation.value * 3.14159,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet,
                                  size: 60,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: AppConstants.paddingLarge),
                      
                      // App name and slogan with fade animation
                      AnimatedBuilder(
                        animation: _textFadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _textFadeAnimation.value,
                            child: Column(
                              children: [
                                Text(
                                  AppStrings.appName,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppConstants.paddingSmall),
                                Text(
                                  AppStrings.appSlogan,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: AppConstants.paddingXLarge),
                      
                      // Loading indicator
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return Column(
                            children: [
                              SizedBox(
                                width: 200,
                                child: LinearProgressIndicator(
                                  value: _progressAnimation.value,
                                  backgroundColor: Colors.white.withOpacity(0.3),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(height: AppConstants.paddingMedium),
                              Text(
                                _getLoadingText(_progressAnimation.value),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              // App version and company info
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingMedium),
                child: Column(
                  children: [
                    Text(
                      'Version ${AppConstants.appVersion}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: AppConstants.paddingSmall),
                    Text(
                      '© 2024 Payroll Management System',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getLoadingText(double progress) {
    if (progress < 0.3) {
      return 'Initializing...';
    } else if (progress < 0.6) {
      return 'Loading configurations...';
    } else if (progress < 0.9) {
      return 'Setting up workspace...';
    } else {
      return 'Almost ready...';
    }
  }
}

// Alternative minimal splash screen
class MinimalSplashScreen extends StatelessWidget {
  const MinimalSplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: AppConstants.paddingLarge),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppConstants.paddingMedium),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}