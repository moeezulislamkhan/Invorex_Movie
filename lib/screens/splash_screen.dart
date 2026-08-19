import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    // Splash screen stays visible for 7 seconds before navigating on.
    Timer(const Duration(seconds: 7), _continue);
  }

  Future<void> _continue() async {
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final onboardingDone = await auth.onboardingComplete();

    if (!mounted) return;

    if (auth.loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } else if (!onboardingDone) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF261017),
              AppTheme.background,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 142,
                    height: 142,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.55),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.22),
                          blurRadius: 45,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/invorex_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, _, __) => Icon(
                        Icons.local_movies_rounded,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        size: 56,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    AppConfig.appName,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'DISCOVER • WATCH • EXPERIENCE',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                      letterSpacing: 2.1,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
