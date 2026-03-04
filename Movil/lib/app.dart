import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'router/app_router.dart';

class EvalProApp extends StatelessWidget {
  const EvalProApp({super.key});

  static final _router = AppRouter.build();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EvalPro Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
