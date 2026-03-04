import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/security/exam_protection_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class ExamPage extends StatefulWidget {
  const ExamPage({
    super.key,
    this.examTitle = 'Evaluación en curso',
    this.duration = const Duration(minutes: 45),
    this.questions = const <ExamQuestion>[],
    this.onSubmit,
  });

  final String examTitle;
  final Duration duration;
  final List<ExamQuestion> questions;
  final Future<void> Function(Map<String, String?> answers)? onSubmit;

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> with TickerProviderStateMixin {
  late final ExamProtectionService _protectionService;
  late final AnimationController _timerPulseController;
  late final List<ExamQuestion> _questions;
  late int _remainingSeconds;

  final Map<String, String?> _answers = <String, String?>{};
  Timer? _timer;

  int _currentQuestionIndex = 0;
  bool _allowPop = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _questions = widget.questions.isEmpty ? _sampleQuestions : widget.questions;
    _remainingSeconds = widget.duration.inSeconds;
    for (final question in _questions) {
      _answers[question.id] = null;
    }

    _protectionService = ExamProtectionService(
      onTelemetry: (event) {
        debugPrint(
          '[ExamProtection] ${event.type.name} ${event.timestamp.toIso8601String()} ${event.metadata}',
        );
      },
    );

    _timerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    unawaited(_protectionService.activate());
    _startTimer();
    _syncTimerPulse();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerPulseController.dispose();
    unawaited(_protectionService.restore());
    _protectionService.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isSubmitting) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 0) {
        timer.cancel();
        return;
      }

      final previous = _remainingSeconds;
      setState(() {
        _remainingSeconds -= 1;
      });

      _handleTimerAlerts(previous: previous, current: _remainingSeconds);
      _syncTimerPulse();

      if (_remainingSeconds == 0) {
        timer.cancel();
        _handleAutoSubmit();
      }
    });
  }

  void _handleTimerAlerts({required int previous, required int current}) {
    if (current <= 60 && current > 0 && current % 30 == 0) {
      HapticFeedback.mediumImpact();
    }
    if (current <= 300 &&
        current > 60 &&
        current % 60 == 0 &&
        current != previous) {
      HapticFeedback.selectionClick();
    }
  }

  void _syncTimerPulse() {
    if (_remainingSeconds <= 300 && _remainingSeconds > 0) {
      if (!_timerPulseController.isAnimating) {
        _timerPulseController.repeat(reverse: true);
      }
      return;
    }
    if (_timerPulseController.isAnimating) {
      _timerPulseController.stop();
      _timerPulseController.value = 0;
    }
  }

  Future<void> _handleAutoSubmit() async {
    await _submitExam(isAutomatic: true);
  }

  ExamQuestion get _currentQuestion => _questions[_currentQuestionIndex];

  int get _answeredCount =>
      _answers.values.where((answer) => answer != null).length;

  List<int> get _unansweredIndices {
    final indices = <int>[];
    for (var i = 0; i < _questions.length; i++) {
      if (_answers[_questions[i].id] == null) {
        indices.add(i);
      }
    }
    return indices;
  }

  String _formattedTime(int seconds) {
    final safe = seconds < 0 ? 0 : seconds;
    final h = safe ~/ 3600;
    final m = (safe % 3600) ~/ 60;
    final s = safe % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_remainingSeconds > 600) {
      return AppColors.examTextSecondary;
    }
    if (_remainingSeconds > 300) {
      return AppColors.warning;
    }
    return AppColors.error;
  }

  FontWeight get _timerWeight {
    if (_remainingSeconds < 60) {
      return FontWeight.w800;
    }
    if (_remainingSeconds <= 300) {
      return FontWeight.w700;
    }
    return FontWeight.w600;
  }

  Future<void> _openQuestionNavigator() async {
    var selectedIndex = _currentQuestionIndex;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.55,
              maxChildSize: 0.85,
              minChildSize: 0.35,
              expand: false,
              builder: (context, controller) {
                final allAnswered = _unansweredIndices.isEmpty;

                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.examCard,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.slate600,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusFull,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      Text(
                        'Navegador de preguntas',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.examText,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      Expanded(
                        child: GridView.builder(
                          controller: controller,
                          itemCount: _questions.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: AppSpacing.sm,
                            crossAxisSpacing: AppSpacing.sm,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            final isAnswered =
                                _answers[_questions[index].id] != null;
                            final isCurrent = index == selectedIndex;

                            final backgroundColor = isCurrent
                                ? AppColors.examSelected
                                : (isAnswered
                                    ? AppColors.examAccent
                                    : AppColors.slate700);
                            final borderColor = isCurrent
                                ? AppColors.examSelectedBorder
                                : Colors.transparent;
                            final textColor = isAnswered || isCurrent
                                ? AppColors.examText
                                : AppColors.slate400;

                            return Semantics(
                              button: true,
                              label: 'Pregunta ${index + 1}',
                              child: InkWell(
                                onTap: () {
                                  setSheetState(() {
                                    selectedIndex = index;
                                  });
                                },
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSm,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 140),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm,
                                    ),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      _ExamActionButton(
                        label: 'Ir a la pregunta',
                        color: AppColors.examAccent,
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _currentQuestionIndex = selectedIndex;
                          });
                        },
                      ),
                      if (allAnswered) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _ExamActionButton(
                          label: 'Enviar examen',
                          color: AppColors.success,
                          onPressed: () {
                            Navigator.of(context).pop();
                            _openSubmitSheet();
                          },
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _openSubmitSheet() async {
    final unanswered = _unansweredIndices;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.examCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.base,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.slate600,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                Text(
                  '¿Enviar examen?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.examText,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Respondiste $_answeredCount de ${_questions.length} preguntas.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.examTextSecondary,
                  ),
                ),
                if (unanswered.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${unanswered.length} preguntas sin responder',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 140),
                    child: ListView.builder(
                      itemCount: unanswered.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '• Pregunta ${unanswered[index] + 1}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.examTextSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.base),
                Text(
                  'Tiempo restante: ${_formattedTime(_remainingSeconds)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: _timerColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _ExamActionButton(
                  label: 'Revisar preguntas',
                  color: AppColors.slate700,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ExamActionButton(
                  label: 'Enviar de todas formas',
                  color: AppColors.success,
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _submitExam(isAutomatic: false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitExam({required bool isAutomatic}) async {
    if (_isSubmitting) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    _timer?.cancel();

    await widget.onSubmit?.call(Map<String, String?>.from(_answers));

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          isAutomatic
              ? 'Tiempo agotado. El examen se envió automáticamente.'
              : 'Examen enviado correctamente.',
        ),
      ),
    );

    setState(() {
      _allowPop = true;
    });
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(Map<String, String?>.from(_answers));
    }
  }

  Future<void> _showExitDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: AppColors.examCard,
          title: Text(
            '¿Salir del examen?',
            style:
                theme.textTheme.titleLarge?.copyWith(color: AppColors.examText),
          ),
          content: Text(
            'Tu progreso se guardará pero esta salida quedará registrada.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.examTextSecondary,
            ),
          ),
          actions: [
            SizedBox(
              width: 110,
              child: _ExamActionButton(
                label: 'Cancelar',
                color: AppColors.slate700,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 110,
              child: _ExamActionButton(
                label: 'Salir',
                color: AppColors.error,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        );
      },
    );

    if (shouldExit != true || !mounted) {
      return;
    }
    setState(() {
      _allowPop = true;
    });
    Navigator.of(context).maybePop();
  }

  void _selectOption(String optionId) {
    final questionId = _currentQuestion.id;
    setState(() {
      _answers[questionId] = optionId;
    });
    HapticFeedback.selectionClick();
  }

  void _goPrevious() {
    if (_currentQuestionIndex == 0) {
      return;
    }
    setState(() {
      _currentQuestionIndex -= 1;
    });
  }

  void _goNext() {
    if (_currentQuestionIndex >= _questions.length - 1) {
      _openSubmitSheet();
      return;
    }
    setState(() {
      _currentQuestionIndex += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return AnimatedBuilder(
      animation: _protectionService,
      builder: (context, _) {
        return Stack(
          children: [
            ExamPopScope(
              canPop: _allowPop,
              onBackAttempt: _showExitDialog,
              child: Scaffold(
                backgroundColor: AppColors.examSurface,
                body: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        color: AppColors.examCard,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _showExitDialog,
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppColors.examText,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Pregunta ${_currentQuestionIndex + 1}/${_questions.length}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.examText,
                                    ),
                              ),
                            ),
                            ScaleTransition(
                              scale: Tween<double>(begin: 1, end: 1.08).animate(
                                CurvedAnimation(
                                  parent: _timerPulseController,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                              child: Text(
                                _formattedTime(_remainingSeconds),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  color: _timerColor,
                                  fontWeight: _timerWeight,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _openQuestionNavigator,
                              icon: const Icon(
                                Icons.grid_view_rounded,
                                color: AppColors.examText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: AppColors.slate700,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.examAccent,
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ExamQuestionBadge(
                                text:
                                    'Pregunta ${_currentQuestionIndex + 1} · ${_currentQuestion.typeLabel} · ${_currentQuestion.points} pts',
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Text(
                                _currentQuestion.statement,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: AppColors.examText,
                                      fontWeight: FontWeight.w500,
                                      height: 1.65,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xl2),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _currentQuestion.options.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: AppSpacing.sm + 2),
                                itemBuilder: (context, index) {
                                  final option =
                                      _currentQuestion.options[index];
                                  final selected =
                                      _answers[_currentQuestion.id] ==
                                          option.id;
                                  return _ExamOptionTile(
                                    optionLabel:
                                        String.fromCharCode(65 + index),
                                    optionText: option.text,
                                    selected: selected,
                                    onTap: () => _selectOption(option.id),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: AppColors.examSurface,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.base,
                          AppSpacing.base,
                          AppSpacing.base,
                          AppSpacing.base,
                        ),
                        child: SafeArea(
                          top: false,
                          child: Row(
                            children: [
                              Expanded(
                                child: _ExamActionButton(
                                  label: '← Anterior',
                                  color: AppColors.slate700,
                                  textColor: AppColors.examText,
                                  onPressed: _currentQuestionIndex == 0
                                      ? null
                                      : _goPrevious,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.base),
                              Expanded(
                                child: _currentQuestionIndex ==
                                        _questions.length - 1
                                    ? _ExamActionButton(
                                        label: 'Enviar examen ✓',
                                        color: AppColors.success,
                                        onPressed: _openSubmitSheet,
                                      )
                                    : _ExamActionButton(
                                        label: 'Siguiente →',
                                        color: AppColors.examAccent,
                                        onPressed: _goNext,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ExamProtectionOverlay(
              visible: _protectionService.showWarningOverlay,
              exitCount: _protectionService.backgroundExitCount,
              limit: _protectionService.maxBackgroundExits,
              onContinue: _protectionService.dismissWarningOverlay,
            ),
            if (_isSubmitting)
              Positioned.fill(
                child: ColoredBox(
                  color: AppColors.examSurface.withValues(alpha: 0.65),
                  child: const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.examAccent),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<ExamQuestion> get _sampleQuestions => const <ExamQuestion>[
        ExamQuestion(
          id: 'q1',
          statement:
              '¿Cuál de las siguientes funciones tiene derivada igual a cos(x)?',
          typeLabel: 'Opción múltiple',
          points: 5,
          options: <ExamOption>[
            ExamOption(id: 'q1a', text: 'sin(x)'),
            ExamOption(id: 'q1b', text: 'tan(x)'),
            ExamOption(id: 'q1c', text: 'x²'),
            ExamOption(id: 'q1d', text: 'ln(x)'),
          ],
        ),
        ExamQuestion(
          id: 'q2',
          statement: 'Si un triángulo tiene lados 3, 4 y 5, ¿cuál es su área?',
          typeLabel: 'Opción múltiple',
          points: 5,
          options: <ExamOption>[
            ExamOption(id: 'q2a', text: '6'),
            ExamOption(id: 'q2b', text: '12'),
            ExamOption(id: 'q2c', text: '7.5'),
            ExamOption(id: 'q2d', text: '10'),
          ],
        ),
        ExamQuestion(
          id: 'q3',
          statement: 'El valor de π aproximado a dos decimales es:',
          typeLabel: 'Opción múltiple',
          points: 5,
          options: <ExamOption>[
            ExamOption(id: 'q3a', text: '3.12'),
            ExamOption(id: 'q3b', text: '3.14'),
            ExamOption(id: 'q3c', text: '3.41'),
            ExamOption(id: 'q3d', text: '2.14'),
          ],
        ),
      ];
}

class ExamQuestion {
  const ExamQuestion({
    required this.id,
    required this.statement,
    required this.typeLabel,
    required this.points,
    required this.options,
  });

  final String id;
  final String statement;
  final String typeLabel;
  final int points;
  final List<ExamOption> options;
}

class ExamOption {
  const ExamOption({
    required this.id,
    required this.text,
  });

  final String id;
  final String text;
}

class _ExamQuestionBadge extends StatelessWidget {
  const _ExamQuestionBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.slate700,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.examTextSecondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ExamOptionTile extends StatelessWidget {
  const _ExamOptionTile({
    required this.optionLabel,
    required this.optionText,
    required this.selected,
    required this.onTap,
  });

  final String optionLabel;
  final String optionText;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? AppColors.examSelectedBorder : AppColors.slate700;
    final backgroundColor =
        selected ? AppColors.examSelected : AppColors.examCard;
    final textColor =
        selected ? AppColors.examText : AppColors.examTextSecondary;
    final circleColor = selected ? AppColors.examAccent : AppColors.slate700;
    final circleTextColor = selected ? AppColors.examText : AppColors.slate400;

    return Semantics(
      button: true,
      selected: selected,
      label: 'Opción $optionLabel: $optionText',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          scale: selected ? 1 : 0.98,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppSpacing.md),
              border: Border.all(
                color: borderColor,
                width: selected ? 2 : 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    optionLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: circleTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(width: AppSpacing.base),
                Expanded(
                  child: Text(
                    optionText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: textColor,
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

class _ExamActionButton extends StatefulWidget {
  const _ExamActionButton({
    required this.label,
    required this.color,
    this.textColor = AppColors.examText,
    this.onPressed,
  });

  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onPressed;

  @override
  State<_ExamActionButton> createState() => _ExamActionButtonState();
}

class _ExamActionButtonState extends State<_ExamActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: enabled ? widget.onPressed : null,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          scale: _pressed ? 0.97 : 1,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _pressed
                  ? widget.color.withValues(alpha: 0.85)
                  : widget.color,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              widget.label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: widget.textColor,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
