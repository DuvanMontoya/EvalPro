import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../presentation/pages/auth/login_page.dart';
import '../presentation/pages/splash/splash_page.dart';
import '../presentation/pages/student/assignments/my_exams_page.dart';
import '../presentation/pages/student/exam/exam_page.dart';
import '../presentation/pages/student/exam/pre_exam_page.dart';
import '../presentation/pages/student/exam/result_page.dart';
import '../presentation/pages/student/home/home_student_page.dart';
import '../presentation/pages/student/profile/profile_page.dart';
import '../presentation/pages/teacher/home/home_teacher_page.dart';
import '../presentation/pages/teacher/sessions/session_panel_page.dart';
import '../presentation/widgets/common/connectivity_banner.dart';

class AppRouter {
  AppRouter._();

  static GoRouter build() {
    return GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          pageBuilder: (context, state) {
            return _buildPageWithTransition(
              state: state,
              child: SplashPage(
                resolveAuth: () async => false,
                onResolved: (isAuthenticated) {
                  if (!context.mounted) {
                    return;
                  }
                  context.go(isAuthenticated ? '/student/home' : '/login');
                },
              ),
            );
          },
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) {
            return _buildPageWithTransition(
              state: state,
              child: LoginPage(
                onSubmit: (email, password) async {
                  await Future<void>.delayed(const Duration(milliseconds: 350));
                  final valid = password.length >= 6;
                  if (!valid || !context.mounted) {
                    return false;
                  }
                  if (email.toLowerCase().contains('docente')) {
                    context.go('/teacher/home');
                  } else {
                    context.go('/student/home');
                  }
                  return true;
                },
              ),
            );
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return StudentShellScaffold(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/student/home',
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    state: state,
                    child: const HomeStudentPage(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/student/exams',
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    state: state,
                    child: const MyExamsPage(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/student/results',
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    state: state,
                    child: const ResultPage(),
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/student/profile',
                  pageBuilder: (context, state) => _buildPageWithTransition(
                    state: state,
                    child: const ProfilePage(),
                  ),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/student/pre-exam',
          pageBuilder: (context, state) => _buildPageWithTransition(
            state: state,
            child: const PreExamPage(),
          ),
        ),
        GoRoute(
          path: '/student/exam',
          pageBuilder: (context, state) => _buildPageWithTransition(
            state: state,
            child: const ExamPage(),
            transitionType: SharedAxisTransitionType.vertical,
          ),
        ),
        GoRoute(
          path: '/teacher/home',
          pageBuilder: (context, state) => _buildPageWithTransition(
            state: state,
            child: const HomeTeacherPage(),
          ),
        ),
        GoRoute(
          path: '/teacher/panel-sesion',
          pageBuilder: (context, state) => _buildPageWithTransition(
            state: state,
            child: const SessionPanelPage(),
          ),
        ),
      ],
    );
  }
}

CustomTransitionPage<void> _buildPageWithTransition({
  required Widget child,
  required GoRouterState state,
  SharedAxisTransitionType transitionType = SharedAxisTransitionType.horizontal,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: transitionType,
        fillColor: AppColors.background,
        child: child,
      );
    },
  );
}

class StudentShellScaffold extends StatefulWidget {
  const StudentShellScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<StudentShellScaffold> createState() => _StudentShellScaffoldState();
}

class _StudentShellScaffoldState extends State<StudentShellScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const ConnectivityBanner(isConnected: true),
          Expanded(
            child: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 280),
              transitionBuilder: (child, primary, secondary) {
                return FadeThroughTransition(
                  animation: primary,
                  secondaryAnimation: secondary,
                  fillColor: AppColors.background,
                  child: child,
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(widget.navigationShell.currentIndex),
                child: widget.navigationShell,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_rounded), label: 'Inicio'),
          NavigationDestination(
              icon: Icon(Icons.list_alt_rounded), label: 'Mis Exámenes'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_rounded), label: 'Resultados'),
          NavigationDestination(
              icon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }
}
