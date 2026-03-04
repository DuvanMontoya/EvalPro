import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../widgets/animated/count_up_text.dart';
import '../../../widgets/animated/staggered_list.dart';
import '../../../widgets/common/eval_avatar.dart';
import '../../../widgets/common/eval_badge.dart';
import '../../../widgets/common/eval_button.dart';
import '../../../widgets/common/eval_card.dart';

class HomeTeacherPage extends StatefulWidget {
  const HomeTeacherPage({super.key});

  @override
  State<HomeTeacherPage> createState() => _HomeTeacherPageState();
}

class _HomeTeacherPageState extends State<HomeTeacherPage>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  bool _compactFab = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _scrollController.addListener(() {
      final shouldCompact = _scrollController.offset > 40;
      if (shouldCompact != _compactFab) {
        setState(() {
          _compactFab = shouldCompact;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final activeSessions =
        _sessions.where((session) => session.active).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('EvalPro'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.base),
            child: EvalAvatar(name: 'Dra. Ramírez', size: EvalAvatarSize.md),
          ),
        ],
      ),
      drawer: const _TeacherDrawer(),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: _compactFab
            ? FloatingActionButton(
                key: const ValueKey('fab_compact'),
                onPressed: () {},
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                child: const Icon(Icons.add_rounded),
              )
            : FloatingActionButton.extended(
                key: const ValueKey('fab_extended'),
                onPressed: () {},
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Nueva sesión'),
              ),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.base),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final stat = _stats[index];
                        return SizedBox(
                          width: 140,
                          child: EvalCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CountUpText(
                                  value: stat.value.toDouble(),
                                  style: textTheme.displaySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 28,
                                  ),
                                ),
                                Text(
                                  stat.label,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.slate500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Sesiones activas', style: textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.base),
                  if (activeSessions.isEmpty)
                    EvalCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'No hay sesiones activas',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.base),
                          EvalButton(
                            label: 'Activar sesión',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    )
                  else
                    ...activeSessions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final session = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: StaggeredListItem(
                          index: index,
                          child: EvalCard(
                            onTap: () {},
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    FadeTransition(
                                      opacity: Tween<double>(begin: 0.5, end: 1)
                                          .animate(
                                        CurvedAnimation(
                                          parent: _pulseController,
                                          curve: Curves.easeInOut,
                                        ),
                                      ),
                                      child: Text(
                                        '● ACTIVA',
                                        style: textTheme.labelMedium?.copyWith(
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    EvalBadge(
                                      'Código: ${session.code}',
                                      variant: EvalBadgeVariant.primary,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  session.examName,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${session.group} · ${session.connectedStudents} conectados',
                                  style: textTheme.bodySmall,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    Text(
                                      '⏱ Iniciada hace ${session.startedAgoMinutes} min',
                                      style: textTheme.bodySmall,
                                    ),
                                    const Spacer(),
                                    EvalButton(
                                      label: 'Finalizar →',
                                      size: EvalButtonSize.small,
                                      fullWidth: false,
                                      variant: EvalButtonVariant.ghost,
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mis exámenes recientes',
                          style: textTheme.titleLarge),
                      EvalButton(
                        label: 'Ver todos →',
                        size: EvalButtonSize.small,
                        fullWidth: false,
                        variant: EvalButtonVariant.ghost,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.base),
                  ..._recentExams.take(3).toList().asMap().entries.map((entry) {
                    final index = entry.key + activeSessions.length;
                    final exam = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: StaggeredListItem(
                        index: index,
                        child: EvalCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  EvalBadge(
                                    exam.status,
                                    variant: exam.status == 'Publicado'
                                        ? EvalBadgeVariant.success
                                        : EvalBadgeVariant.neutral,
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.more_horiz_rounded),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                exam.title,
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '${exam.questions} preguntas · ${exam.points} pts · ${exam.minutes} min',
                                style: textTheme.bodySmall,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Modificado: ${exam.updatedText}',
                                style: textTheme.bodySmall
                                    ?.copyWith(color: AppColors.slate500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.xl3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherDrawer extends StatelessWidget {
  const _TeacherDrawer();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Drawer(
      width: 300,
      child: Column(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl2,
              AppSpacing.lg,
              AppSpacing.base,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const EvalAvatar(name: 'Dra. Ramírez', size: EvalAvatarSize.lg),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Dra. Ramírez',
                  style: textTheme.headlineSmall
                      ?.copyWith(color: AppColors.surface),
                ),
                Text(
                  'Docente · Institución Central',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.surface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.sm),
              children: const [
                _DrawerTile(
                    label: 'Mis Exámenes', icon: Icons.assignment_rounded),
                _DrawerTile(
                    label: 'Sesiones',
                    icon: Icons.calendar_month_rounded,
                    active: true),
                _DrawerTile(label: 'Mis Grupos', icon: Icons.group_rounded),
                _DrawerTile(label: 'Reportes', icon: Icons.bar_chart_rounded),
                Divider(),
                _DrawerTile(
                    label: 'Configuración', icon: Icons.settings_rounded),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(AppSpacing.base),
            child: Row(
              children: [
                EvalAvatar(name: 'Dra. Ramírez', size: EvalAvatarSize.sm),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: Text('Cerrar sesión')),
                Icon(Icons.logout_rounded, color: AppColors.error),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.label,
    required this.icon,
    this.active = false,
  });

  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
      tileColor: active ? AppColors.primarySurface : null,
      leading:
          Icon(icon, color: active ? AppColors.primary : AppColors.slate600),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: active ? AppColors.primary : AppColors.slate800,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
      ),
      onTap: () {},
    );
  }
}

class _TeacherStat {
  const _TeacherStat(this.label, this.value);
  final String label;
  final int value;
}

class _ActiveSession {
  const _ActiveSession({
    required this.examName,
    required this.group,
    required this.connectedStudents,
    required this.startedAgoMinutes,
    required this.code,
    required this.active,
  });

  final String examName;
  final String group;
  final int connectedStudents;
  final int startedAgoMinutes;
  final String code;
  final bool active;
}

class _RecentExam {
  const _RecentExam({
    required this.status,
    required this.title,
    required this.questions,
    required this.points,
    required this.minutes,
    required this.updatedText,
  });

  final String status;
  final String title;
  final int questions;
  final int points;
  final int minutes;
  final String updatedText;
}

const _stats = [
  _TeacherStat('Sesiones hoy', 5),
  _TeacherStat('Estudiantes activos', 23),
  _TeacherStat('Pendientes calificar', 8),
];

const _sessions = [
  _ActiveSession(
    examName: 'Álgebra Lineal',
    group: 'Grupo B',
    connectedStudents: 18,
    startedAgoMinutes: 23,
    code: 'AB3X9F',
    active: true,
  ),
  _ActiveSession(
    examName: 'Física I',
    group: 'Grupo A',
    connectedStudents: 0,
    startedAgoMinutes: 0,
    code: 'X2D7K9',
    active: false,
  ),
];

const _recentExams = [
  _RecentExam(
    status: 'Publicado',
    title: 'Cálculo Diferencial e Integral',
    questions: 20,
    points: 100,
    minutes: 60,
    updatedText: 'hace 2 días',
  ),
  _RecentExam(
    status: 'Borrador',
    title: 'Probabilidad y Estadística',
    questions: 15,
    points: 80,
    minutes: 50,
    updatedText: 'hace 5 días',
  ),
  _RecentExam(
    status: 'Publicado',
    title: 'Mecánica Clásica',
    questions: 18,
    points: 90,
    minutes: 55,
    updatedText: 'hace 1 semana',
  ),
];
