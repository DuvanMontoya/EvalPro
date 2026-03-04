import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movil/core/theme/app_theme.dart';
import 'package:movil/presentation/widgets/common/connectivity_banner.dart';
import 'package:movil/presentation/widgets/common/eval_avatar.dart';
import 'package:movil/presentation/widgets/common/eval_badge.dart';
import 'package:movil/presentation/widgets/common/eval_button.dart';
import 'package:movil/presentation/widgets/common/eval_card.dart';
import 'package:movil/presentation/widgets/common/eval_empty_state.dart';
import 'package:movil/presentation/widgets/common/eval_error_state.dart';
import 'package:movil/presentation/widgets/common/eval_shimmer.dart';
import 'package:movil/presentation/widgets/common/eval_text_field.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('EvalButton renders label', (tester) async {
    await tester.pumpWidget(
      _testApp(
        EvalButton(
          label: 'Iniciar sesión',
          onPressed: () {},
        ),
      ),
    );

    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('EvalTextField renders label and error', (tester) async {
    await tester.pumpWidget(
      _testApp(
        const EvalTextField(
          labelText: 'Correo',
          hintText: 'correo@evalpro.com',
          errorText: 'Correo inválido',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Correo'), findsOneWidget);
    expect(find.text('Correo inválido'), findsOneWidget);
  });

  testWidgets('EvalCard renders child', (tester) async {
    await tester.pumpWidget(
      _testApp(
        const EvalCard(
          child: Text('Contenido'),
        ),
      ),
    );

    expect(find.text('Contenido'), findsOneWidget);
  });

  testWidgets('EvalBadge renders uppercase text', (tester) async {
    await tester.pumpWidget(
      _testApp(
        const EvalBadge(
          'en curso',
          variant: EvalBadgeVariant.warning,
        ),
      ),
    );

    expect(find.text('EN CURSO'), findsOneWidget);
  });

  testWidgets('EvalShimmer renders shimmer shapes', (tester) async {
    await tester.pumpWidget(
      _testApp(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShimmerLine(width: 120, height: 14),
            SizedBox(height: 8),
            ShimmerCircle(size: 24),
            SizedBox(height: 8),
            ShimmerCard(height: 60),
          ],
        ),
      ),
    );

    expect(find.byType(ShimmerLine), findsOneWidget);
    expect(find.byType(ShimmerCircle), findsOneWidget);
    expect(find.byType(ShimmerCard), findsOneWidget);
  });

  testWidgets('EvalEmptyState renders content', (tester) async {
    await tester.pumpWidget(
      _testApp(
        const EvalEmptyState(
          icon: Icons.assignment_rounded,
          title: 'Sin datos',
          subtitle: 'No hay información para mostrar.',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin datos'), findsOneWidget);
    expect(find.text('No hay información para mostrar.'), findsOneWidget);
  });

  testWidgets('EvalErrorState renders retry action', (tester) async {
    await tester.pumpWidget(
      _testApp(
        EvalErrorState(
          message: 'Error de red',
          onRetry: () {},
        ),
      ),
    );

    expect(find.text('Algo salió mal'), findsOneWidget);
    expect(find.text('Error de red'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('EvalAvatar renders fallback initials', (tester) async {
    await tester.pumpWidget(
      _testApp(
        const EvalAvatar(
          name: 'Ada Lovelace',
          size: EvalAvatarSize.lg,
          isOnline: true,
        ),
      ),
    );

    expect(find.text('AL'), findsOneWidget);
  });

  testWidgets('ConnectivityBanner renders disconnected state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Column(
            children: [
              ConnectivityBanner(isConnected: false),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Sin conexión · Reconectando...'), findsOneWidget);
  });
}

Widget _testApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}
