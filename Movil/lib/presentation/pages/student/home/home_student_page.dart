import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../widgets/animated/count_up_text.dart';
import '../../../widgets/animated/staggered_list.dart';
import '../../../widgets/common/eval_avatar.dart';
import '../../../widgets/common/eval_badge.dart';
import '../../../widgets/common/eval_button.dart';
import '../../../widgets/common/eval_card.dart';
import '../../../widgets/common/eval_empty_state.dart';
import '../../../widgets/common/eval_error_state.dart';
import '../../../widgets/common/eval_shimmer.dart';

class HomeStudentPage extends StatefulWidget {
  const HomeStudentPage({super.key});

  @override
  State<HomeStudentPage> createState() => _HomeStudentPageState();
}

class _HomeStudentPageState extends State<HomeStudentPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _badgePulseController;
  HomeStudentUiState _state = const HomeStudentUiState.loading();

  @override
  void initState() {
    super.initState();
    _badgePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _load();
  }

  Future<void> _load() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) {
      return;
    }
    setState(() {
      _state = HomeStudentUiState.data(_mockData);
    });
  }

  @override
  void dispose() {
    _badgePulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: switch (_state) {
        HomeStudentUiStateLoading() => _buildLoading(),
        HomeStudentUiStateError(:final message) => EvalErrorState(
            key: const ValueKey('home_error'),
            message: message,
            onRetry: _load,
          ),
        HomeStudentUiStateData(:final data) when data.upcoming.isEmpty =>
          const EvalEmptyState(
            key: ValueKey('home_empty'),
            icon: Icons.assignment_outlined,
            title: 'Sin evaluaciones próximas',
            subtitle:
                'Cuando tu docente active nuevas sesiones, aparecerán aquí.',
          ),
        HomeStudentUiStateData(:final data) => _buildContent(data),
      },
    );
  }

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView(
        key: const ValueKey('home_loading'),
        padding: const EdgeInsets.all(AppSpacing.base),
        children: const [
          SizedBox(height: 16),
          ShimmerCard(height: 180),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: ShimmerCard(height: 90)),
              SizedBox(width: 8),
              Expanded(child: ShimmerCard(height: 90)),
              SizedBox(width: 8),
              Expanded(child: ShimmerCard(height: 90)),
            ],
          ),
          SizedBox(height: 24),
          ShimmerLine(width: 160, height: 20),
          SizedBox(height: 12),
          ShimmerCard(height: 80),
          SizedBox(height: 8),
          ShimmerCard(height: 80),
          SizedBox(height: 8),
          ShimmerCard(height: 80),
        ],
      ),
    );
  }

  Widget _buildContent(HomeStudentData data) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        key: const ValueKey('home_data'),
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            title: const Text('EvalPro'),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: AppSpacing.base),
                child: EvalAvatar(name: 'Juan Pérez', size: EvalAvatarSize.md),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.xl2,
                  AppSpacing.base,
                  AppSpacing.base,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buenos días, Juan 👋',
                            style: textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Institución Central · 2026-1',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const EvalAvatar(
                      name: 'Juan Pérez',
                      size: EvalAvatarSize.xl,
                      customSize: 80,
                      isOnline: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.base),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  if (data.activeSession != null)
                    _buildActiveSessionCard(data.activeSession!),
                  if (data.activeSession != null)
                    const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Próximas evaluaciones',
                          style: textTheme.titleLarge),
                      EvalButton(
                        label: 'Ver todas →',
                        variant: EvalButtonVariant.ghost,
                        size: EvalButtonSize.small,
                        fullWidth: false,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  ...data.upcoming
                      .take(3)
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                    return StaggeredListItem(
                      index: entry.key,
                      child: _buildUpcomingCard(entry.value),
                    );
                  }),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Resultados recientes', style: textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.base),
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: data.recentResults.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final result = data.recentResults[index];
                        return SizedBox(
                          width: 160,
                          child: EvalCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result.examName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                CountUpText(
                                  value: result.percentage.toDouble(),
                                  suffix: '%',
                                  style: textTheme.displaySmall?.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                EvalBadge(
                                  result.label,
                                  variant: result.variant,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionCard(HomeActiveSession session) {
    final textTheme = Theme.of(context).textTheme;
    return EvalCard(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 1).animate(
                CurvedAnimation(
                  parent: _badgePulseController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 1, end: 1.1).animate(
                  CurvedAnimation(
                    parent: _badgePulseController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Text(
                  '● EN CURSO',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.surface.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              session.examName,
              style:
                  textTheme.headlineSmall?.copyWith(color: AppColors.surface),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${session.group} · ${session.teacher}',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.surface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Divider(color: AppColors.surface.withValues(alpha: 0.25)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '⏱ Tiempo restante: ${session.timeRemaining}',
              style: textTheme.headlineSmall?.copyWith(
                color: AppColors.surface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            EvalButton(
              label: 'Continuar examen →',
              size: EvalButtonSize.small,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(HomeUpcomingExam exam) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: EvalCard(
        onTap: () {},
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: exam.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(Icons.assignment_rounded, color: exam.color),
            ),
            const SizedBox(width: AppSpacing.base),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.examName,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${exam.group} · ${exam.teacher}',
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.slate500),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    exam.scheduleText,
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            EvalBadge(exam.statusLabel, variant: exam.statusVariant),
          ],
        ),
      ),
    );
  }

  HomeStudentData get _mockData => HomeStudentData(
        activeSession: const HomeActiveSession(
          examName: 'Cálculo Diferencial',
          group: 'Grupo A',
          teacher: 'Dra. Ramírez',
          timeRemaining: '00:45:23',
        ),
        upcoming: const [
          HomeUpcomingExam(
            examName: 'Física I',
            group: 'Grupo A',
            teacher: 'Ing. Herrera',
            scheduleText: '📅 Abre en 2h',
            statusLabel: 'Disponible',
            statusVariant: EvalBadgeVariant.success,
            color: AppColors.success,
          ),
          HomeUpcomingExam(
            examName: 'Álgebra Lineal',
            group: 'Grupo B',
            teacher: 'Lic. Gómez',
            scheduleText: '📅 Hasta las 15:30',
            statusLabel: 'Próximamente',
            statusVariant: EvalBadgeVariant.neutral,
            color: AppColors.primary,
          ),
          HomeUpcomingExam(
            examName: 'Probabilidad',
            group: 'Grupo C',
            teacher: 'Prof. Ortega',
            scheduleText: '📅 Mañana 08:00',
            statusLabel: 'Próximamente',
            statusVariant: EvalBadgeVariant.neutral,
            color: AppColors.warning,
          ),
        ],
        recentResults: const [
          HomeRecentResult(
            examName: 'Cálculo I',
            percentage: 85,
            label: 'Aprobado',
            variant: EvalBadgeVariant.success,
          ),
          HomeRecentResult(
            examName: 'Química',
            percentage: 62,
            label: 'Revisar',
            variant: EvalBadgeVariant.warning,
          ),
        ],
      );
}

sealed class HomeStudentUiState {
  const HomeStudentUiState();
  const factory HomeStudentUiState.loading() = HomeStudentUiStateLoading;
  const factory HomeStudentUiState.error(String message) =
      HomeStudentUiStateError;
  const factory HomeStudentUiState.data(HomeStudentData data) =
      HomeStudentUiStateData;
}

class HomeStudentUiStateLoading extends HomeStudentUiState {
  const HomeStudentUiStateLoading();
}

class HomeStudentUiStateError extends HomeStudentUiState {
  const HomeStudentUiStateError(this.message);
  final String message;
}

class HomeStudentUiStateData extends HomeStudentUiState {
  const HomeStudentUiStateData(this.data);
  final HomeStudentData data;
}

class HomeStudentData {
  const HomeStudentData({
    required this.activeSession,
    required this.upcoming,
    required this.recentResults,
  });

  final HomeActiveSession? activeSession;
  final List<HomeUpcomingExam> upcoming;
  final List<HomeRecentResult> recentResults;
}

class HomeActiveSession {
  const HomeActiveSession({
    required this.examName,
    required this.group,
    required this.teacher,
    required this.timeRemaining,
  });

  final String examName;
  final String group;
  final String teacher;
  final String timeRemaining;
}

class HomeUpcomingExam {
  const HomeUpcomingExam({
    required this.examName,
    required this.group,
    required this.teacher,
    required this.scheduleText,
    required this.statusLabel,
    required this.statusVariant,
    required this.color,
  });

  final String examName;
  final String group;
  final String teacher;
  final String scheduleText;
  final String statusLabel;
  final EvalBadgeVariant statusVariant;
  final Color color;
}

class HomeRecentResult {
  const HomeRecentResult({
    required this.examName,
    required this.percentage,
    required this.label,
    required this.variant,
  });

  final String examName;
  final int percentage;
  final String label;
  final EvalBadgeVariant variant;
}
