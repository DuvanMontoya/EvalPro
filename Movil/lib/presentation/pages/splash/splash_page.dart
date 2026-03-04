import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    this.onResolved,
    this.resolveAuth,
    super.key,
  });

  final Future<bool> Function()? resolveAuth;
  final void Function(bool isAuthenticated)? onResolved;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _nameController;
  late final AnimationController _taglineController;
  late final AnimationController _exitController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _nameFade;
  late final Animation<Offset> _nameSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _exitFade;

  bool _showSpinner = false;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _nameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = CurvedAnimation(parent: _logoController, curve: Curves.easeOut);
    _nameFade = CurvedAnimation(parent: _nameController, curve: Curves.easeOut);
    _nameSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _nameController, curve: Curves.easeOut));
    _taglineFade =
        CurvedAnimation(parent: _taglineController, curve: Curves.easeOut);
    _exitFade = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: _exitController, curve: Curves.easeOut));

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (!mounted) {
      return;
    }
    _logoController.forward();

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) {
      return;
    }
    _nameController.forward();

    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted) {
      return;
    }
    _taglineController.forward();

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) {
      return;
    }
    _resolveAuthentication();
  }

  Future<void> _resolveAuthentication() async {
    bool isAuthenticated = false;
    var authReady = false;

    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        if (!mounted || authReady) {
          return;
        }
        setState(() {
          _showSpinner = true;
        });
      }),
    );

    final resolver = widget.resolveAuth;
    if (resolver != null) {
      isAuthenticated = await resolver();
    }
    authReady = true;

    if (!mounted || _resolved) {
      return;
    }
    _resolved = true;
    await _exitController.forward();
    widget.onResolved?.call(isAuthenticated);
  }

  @override
  void dispose() {
    _logoController.dispose();
    _nameController.dispose();
    _taglineController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return FadeTransition(
      opacity: _exitFade,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusLg),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: AppColors.surface,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeTransition(
                      opacity: _nameFade,
                      child: SlideTransition(
                        position: _nameSlide,
                        child: Text('EvalPro', style: textTheme.displaySmall),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FadeTransition(
                      opacity: _taglineFade,
                      child: Text(
                        'Tu plataforma de evaluación académica',
                        style: textTheme.bodyMedium
                            ?.copyWith(color: AppColors.slate400),
                      ),
                    ),
                    if (_showSpinner) ...[
                      const SizedBox(height: AppSpacing.lg),
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.base),
                  child: Text(
                    'v1.0.0',
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.slate400),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
