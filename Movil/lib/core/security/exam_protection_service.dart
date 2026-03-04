import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../../presentation/widgets/common/eval_button.dart';

enum ExamProtectionEventType {
  segundoPlano,
  focoRecuperado,
  capturaPantallaDetectada,
}

class ExamProtectionEvent {
  const ExamProtectionEvent({
    required this.type,
    required this.timestamp,
    this.metadata = const <String, Object?>{},
  });

  final ExamProtectionEventType type;
  final DateTime timestamp;
  final Map<String, Object?> metadata;
}

typedef ExamProtectionTelemetry = void Function(ExamProtectionEvent event);

class ExamProtectionService extends ChangeNotifier {
  ExamProtectionService({
    this.maxBackgroundExits = 3,
    this.onTelemetry,
  });

  final int maxBackgroundExits;
  final ExamProtectionTelemetry? onTelemetry;

  AppLifecycleListener? _lifecycleListener;
  ScreenshotCallback? _screenshotCallback;
  Timer? _immersiveRestoreTimer;

  bool _isActive = false;
  bool _showWarningOverlay = false;
  int _backgroundExitCount = 0;

  bool get isActive => _isActive;
  bool get showWarningOverlay => _showWarningOverlay;
  int get backgroundExitCount => _backgroundExitCount;
  bool get reachedBackgroundExitLimit =>
      _backgroundExitCount >= maxBackgroundExits;
  bool get shouldMarkAttemptForReview => reachedBackgroundExitLimit;

  Future<void> activate() async {
    if (_isActive) {
      return;
    }
    _isActive = true;
    _showWarningOverlay = false;

    await _enableSystemProtection();
    await _enableScreenshotProtection();
    await WakelockPlus.enable();
    _attachLifecycleListener();
    _attachSystemUiVisibilityHandler();
    notifyListeners();
  }

  Future<void> restore() async {
    _immersiveRestoreTimer?.cancel();
    _immersiveRestoreTimer = null;

    _lifecycleListener?.dispose();
    _lifecycleListener = null;

    try {
      await _screenshotCallback?.dispose();
    } catch (_) {
      // Ignore plugin dispose exceptions during teardown.
    }
    _screenshotCallback = null;

    await WakelockPlus.disable();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[]);
    await SystemChrome.setSystemUIChangeCallback(null);

    if (Platform.isAndroid) {
      await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }

    _isActive = false;
    _showWarningOverlay = false;
    notifyListeners();
  }

  Future<void> _enableSystemProtection() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations(
      const <DeviceOrientation>[DeviceOrientation.portraitUp],
    );
  }

  Future<void> _enableScreenshotProtection() async {
    if (Platform.isAndroid) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
    if (Platform.isIOS) {
      final callback = ScreenshotCallback();
      callback.addListener(() {
        _emitTelemetry(ExamProtectionEventType.capturaPantallaDetectada);
      });
      _screenshotCallback = callback;
    }
  }

  void _attachLifecycleListener() {
    _lifecycleListener = AppLifecycleListener(
      onStateChange: (state) {
        if (!_isActive) {
          return;
        }
        if (state == AppLifecycleState.paused) {
          _backgroundExitCount += 1;
          _showWarningOverlay = true;
          _emitTelemetry(
            ExamProtectionEventType.segundoPlano,
            metadata: <String, Object?>{
              'salidasRegistradas': _backgroundExitCount,
              'limiteSalidas': maxBackgroundExits,
            },
          );
          notifyListeners();
          return;
        }
        if (state == AppLifecycleState.resumed) {
          _emitTelemetry(
            ExamProtectionEventType.focoRecuperado,
            metadata: <String, Object?>{
              'salidasRegistradas': _backgroundExitCount,
            },
          );
          notifyListeners();
        }
      },
    );
  }

  void _attachSystemUiVisibilityHandler() {
    SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
      if (!_isActive || !systemOverlaysAreVisible) {
        return;
      }
      _immersiveRestoreTimer?.cancel();
      _immersiveRestoreTimer = Timer(const Duration(seconds: 1), () {
        if (_isActive) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        }
      });
    });
  }

  void dismissWarningOverlay() {
    if (!_showWarningOverlay) {
      return;
    }
    _showWarningOverlay = false;
    notifyListeners();
  }

  void _emitTelemetry(
    ExamProtectionEventType type, {
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    onTelemetry?.call(
      ExamProtectionEvent(
        type: type,
        timestamp: DateTime.now().toUtc(),
        metadata: metadata,
      ),
    );
  }

  @override
  void dispose() {
    _immersiveRestoreTimer?.cancel();
    _lifecycleListener?.dispose();
    _screenshotCallback?.dispose();
    super.dispose();
  }
}

class ExamPopScope extends StatelessWidget {
  const ExamPopScope({
    required this.child,
    required this.onBackAttempt,
    this.canPop = false,
    super.key,
  });

  final Widget child;
  final VoidCallback onBackAttempt;
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          onBackAttempt();
        }
      },
      child: child,
    );
  }
}

class ExamProtectionOverlay extends StatelessWidget {
  const ExamProtectionOverlay({
    required this.visible,
    required this.exitCount,
    required this.limit,
    required this.onContinue,
    super.key,
  });

  final bool visible;
  final int exitCount;
  final int limit;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final reachedLimit = exitCount >= limit;

    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.slate900.withValues(alpha: 0.7),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.examCard,
                  borderRadius: BorderRadius.circular(AppSpacing.lg + 2),
                  boxShadow: AppSpacing.shadowXl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_rounded,
                          color: AppColors.warning,
                          size: 22,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Salida detectada',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppColors.examText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Saliste de la aplicación durante el examen. '
                      'Esta acción ha sido registrada.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.examTextSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Salidas registradas: $exitCount de $limit permitidas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.examText,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Al superar el límite, tu intento será marcado para revisión.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.examTextSecondary,
                      ),
                    ),
                    if (reachedLimit) ...[
                      const SizedBox(height: AppSpacing.base),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.base),
                        decoration: BoxDecoration(
                          color: AppColors.errorSurface.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                          border: Border.all(color: AppColors.errorBorder),
                        ),
                        child: Text(
                          'Límite superado. Tu intento quedó marcado para '
                          'revisión docente.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    EvalButton(
                      label: 'Entendido — Continuar examen',
                      onPressed: onContinue,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
