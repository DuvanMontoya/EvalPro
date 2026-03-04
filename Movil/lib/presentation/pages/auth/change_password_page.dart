import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/haptics.dart';
import '../../widgets/common/eval_button.dart';
import '../../widgets/common/eval_card.dart';
import '../../widgets/common/eval_text_field.dart';

/// First-login forced password change screen (AGENTS.md § 4.3).
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({this.onPasswordChanged, super.key});

  /// Called after the password was successfully updated.
  final VoidCallback? onPasswordChanged;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _isSubmitting = false;
  bool _showRequirements = false;

  // ── requirement flags ──────────────────────────────────────
  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  bool get _passwordsMatch =>
      _passwordController.text == _confirmController.text &&
      _confirmController.text.isNotEmpty;
  bool get _allRequirementsMet =>
      _hasMinLength && _hasUppercase && _hasNumber && _hasSpecial;
  bool get _canSubmit => _allRequirementsMet && _passwordsMatch;

  @override
  void initState() {
    super.initState();
    _passwordFocus.addListener(_onPasswordFocusChanged);
    _passwordController.addListener(_onTextChanged);
    _confirmController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _passwordFocus.removeListener(_onPasswordFocusChanged);
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _onPasswordFocusChanged() {
    if (_passwordFocus.hasFocus && !_showRequirements) {
      setState(() => _showRequirements = true);
    }
  }

  void _onTextChanged() => setState(() {});

  Future<void> _submit() async {
    if (!_canSubmit || _isSubmitting) return;
    Haptics.light();
    setState(() => _isSubmitting = true);

    // TODO: call actual password-change API here.
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    widget.onPasswordChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configura tu contraseña'),
        automaticallyImplyLeading: false, // no back button — mandatory flow
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Info banner ──────────────────────────────────
              EvalCard(
                backgroundColor: AppColors.primarySurface,
                borderColor: AppColors.primaryBorder,
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Por seguridad, debes establecer una '
                        'contraseña personal.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.slate700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── New password field ──────────────────────────
              EvalTextField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                labelText: 'Nueva contraseña',
                isPassword: true,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_confirmFocus),
              ),

              // ── Inline requirements ─────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1,
                      child: child,
                    ),
                  );
                },
                child: _showRequirements
                    ? Padding(
                        key: const ValueKey('requirements-visible'),
                        padding: const EdgeInsets.only(top: AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _RequirementRow(
                              label: 'Mínimo 8 caracteres',
                              met: _hasMinLength,
                            ),
                            _RequirementRow(
                              label: 'Una mayúscula',
                              met: _hasUppercase,
                            ),
                            _RequirementRow(
                              label: 'Un número',
                              met: _hasNumber,
                            ),
                            _RequirementRow(
                              label: 'Un carácter especial',
                              met: _hasSpecial,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(
                        key: ValueKey('requirements-hidden'),
                      ),
              ),

              const SizedBox(height: AppSpacing.base),

              // ── Confirm password field ──────────────────────
              EvalTextField(
                controller: _confirmController,
                focusNode: _confirmFocus,
                labelText: 'Confirmar contraseña',
                isPassword: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                errorText: _confirmController.text.isNotEmpty &&
                        !_passwordsMatch
                    ? 'Las contraseñas no coinciden'
                    : null,
              ),

              const SizedBox(height: AppSpacing.xl2),

              // ── Submit button ───────────────────────────────
              EvalButton(
                label: 'Establecer contraseña',
                onPressed: _canSubmit ? _submit : null,
                isLoading: _isSubmitting,
                semanticLabel: 'Establecer nueva contraseña',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────
// Private helpers
// ───────────────────────────────────────────────────────────────

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final color = met ? AppColors.success : AppColors.slate300;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Icon(
              met ? Icons.check_circle_rounded : Icons.circle_outlined,
              key: ValueKey(met),
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
