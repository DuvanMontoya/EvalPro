import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../widgets/common/eval_button.dart';
import '../../widgets/common/eval_card.dart';
import '../../widgets/common/eval_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    this.onSubmit,
    super.key,
  });

  final Future<bool> Function(String email, String password)? onSubmit;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  late final AnimationController _shakeController;
  late final Animation<Offset> _shakeAnimation;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnimation = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(-0.03, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-0.03, 0), end: const Offset(0.03, 0)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(0.03, 0), end: Offset.zero),
        weight: 1,
      ),
    ]).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    _passwordFocus.addListener(() {
      if (_passwordFocus.hasFocus) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    _scrollController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Completa correo y contraseña.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final handler = widget.onSubmit;
    var ok = true;
    if (handler != null) {
      ok = await handler(email, password);
    }

    if (!mounted) {
      return;
    }

    if (!ok) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Correo o contraseña incorrectos';
      });
      _shakeController.forward(from: 0);
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xl2 + AppSpacing.base),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: AppColors.surface,
                    size: 24,
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                Text('EvalPro', style: textTheme.displaySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ingresa a tu cuenta',
                  style:
                      textTheme.titleLarge?.copyWith(color: AppColors.slate500),
                ),
                const SizedBox(height: AppSpacing.xl),
                SlideTransition(
                  position: _shakeAnimation,
                  child: EvalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EvalTextField(
                          controller: _emailController,
                          labelText: 'Correo electrónico',
                          hintText: 'correo@institucion.edu',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _passwordFocus.requestFocus(),
                          autofillHints: const [AutofillHints.username],
                        ),
                        const SizedBox(height: AppSpacing.base),
                        EvalTextField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          labelText: 'Contraseña',
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          autofillHints: const [AutofillHints.password],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Align(
                          alignment: Alignment.centerRight,
                          child: EvalButton(
                            label: '¿Olvidaste tu contraseña?',
                            variant: EvalButtonVariant.ghost,
                            size: EvalButtonSize.small,
                            fullWidth: false,
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _errorMessage == null
                              ? const SizedBox.shrink()
                              : Padding(
                                  key: const ValueKey('login_error'),
                                  padding: const EdgeInsets.only(
                                      bottom: AppSpacing.base),
                                  child: Container(
                                    padding:
                                        const EdgeInsets.all(AppSpacing.base),
                                    decoration: BoxDecoration(
                                      color: AppColors.errorSurface,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm,
                                      ),
                                      border: Border.all(
                                          color: AppColors.errorBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          color: AppColors.error,
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style:
                                                textTheme.bodyMedium?.copyWith(
                                              color: AppColors.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                        EvalButton(
                          label: 'Iniciar sesión',
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl3),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        '¿Primer acceso? ',
                        style: textTheme.bodySmall
                            ?.copyWith(color: AppColors.slate500),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Usa tu credencial temporal',
                          style: textTheme.bodySmall
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
