import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../widgets/animated/staggered_list.dart';
import '../../../widgets/common/eval_badge.dart';
import '../../../widgets/common/eval_card.dart';
import '../../../widgets/common/eval_empty_state.dart';
import '../../../widgets/common/eval_shimmer.dart';

class MyExamsPage extends StatefulWidget {
  const MyExamsPage({super.key});

  @override
  State<MyExamsPage> createState() => _MyExamsPageState();
}

class _MyExamsPageState extends State<MyExamsPage> {
  MyExamsFilter _activeFilter = MyExamsFilter.all;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = false;
    });
  }

  List<MyExamItem> get _filteredItems {
    if (_activeFilter == MyExamsFilter.all) {
      return _mockItems;
    }
    return _mockItems.where((item) => item.filter == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _isLoading
            ? _buildLoading()
            : RefreshIndicator(
                onRefresh: () async {
                  HapticFeedback.mediumImpact();
                  await _load();
                },
                color: AppColors.primary,
                strokeWidth: 2.5,
                child: CustomScrollView(
                  key: const ValueKey('my_exams_data'),
                  slivers: [
                    SliverAppBar.large(
                      title: const Text('Mis Evaluaciones'),
                      backgroundColor: AppColors.background,
                      surfaceTintColor: Colors.transparent,
                      pinned: true,
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _FilterHeaderDelegate(
                        minExtent: 64,
                        maxExtent: 64,
                        child: Container(
                          color: AppColors.background,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.base,
                          ),
                          alignment: Alignment.centerLeft,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: MyExamsFilter.values.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final filter = MyExamsFilter.values[index];
                              final selected = filter == _activeFilter;
                              return ChoiceChip(
                                label: Text(filter.label),
                                selected: selected,
                                onSelected: (_) {
                                  setState(() {
                                    _activeFilter = filter;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.base),
                      sliver: _filteredItems.isEmpty
                          ? SliverFillRemaining(
                              hasScrollBody: false,
                              child: EvalEmptyState(
                                icon: Icons.assignment_rounded,
                                title: 'No tienes evaluaciones asignadas',
                                subtitle:
                                    'Cuando tu docente asigne una evaluación, aparecerá aquí.',
                                actionLabel: 'Actualizar',
                                onAction: _load,
                              ),
                            )
                          : SliverList.separated(
                              itemCount: _filteredItems.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                return StaggeredListItem(
                                  index: index,
                                  child: EvalCard(
                                    onTap: () {},
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                AppColors.primary,
                                                AppColors.primaryDark,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusSm,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.assignment_turned_in_rounded,
                                            color: AppColors.surface,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.base),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.examName,
                                                style: textTheme.titleLarge
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height: AppSpacing.xs),
                                              Text(
                                                '${item.group} · ${item.teacher}',
                                                style: textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: AppColors.slate500,
                                                ),
                                              ),
                                              const SizedBox(
                                                  height: AppSpacing.sm),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      item.dateText,
                                                      style:
                                                          textTheme.bodySmall,
                                                    ),
                                                  ),
                                                  EvalBadge(
                                                    item.badgeLabel,
                                                    variant: item.badgeVariant,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                  height: AppSpacing.xs),
                                              Text(
                                                '⏱ Duración: ${item.durationMinutes} min',
                                                style: textTheme.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppColors.slate400,
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
    );
  }

  Widget _buildLoading() {
    return ListView(
      key: const ValueKey('my_exams_loading'),
      padding: const EdgeInsets.all(AppSpacing.base),
      children: List<Widget>.generate(
        5,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: Row(
            children: [
              ShimmerCircle(size: 44),
              SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  children: [
                    ShimmerLine(width: double.infinity, height: 16),
                    SizedBox(height: AppSpacing.sm),
                    ShimmerLine(width: 180, height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<MyExamItem> get _mockItems => const [
        MyExamItem(
          examName: 'Cálculo I',
          group: 'Grupo A',
          teacher: 'Dra. Ramírez',
          dateText: '📅 Hoy 15:30',
          durationMinutes: 60,
          badgeLabel: 'Disponible',
          badgeVariant: EvalBadgeVariant.success,
          filter: MyExamsFilter.inProgress,
        ),
        MyExamItem(
          examName: 'Física I',
          group: 'Grupo A',
          teacher: 'Ing. Herrera',
          dateText: '📅 Mañana 08:00',
          durationMinutes: 45,
          badgeLabel: 'Próximamente',
          badgeVariant: EvalBadgeVariant.neutral,
          filter: MyExamsFilter.upcoming,
        ),
        MyExamItem(
          examName: 'Química General',
          group: 'Grupo B',
          teacher: 'Lic. Rojas',
          dateText: '📅 Enviada 12:50',
          durationMinutes: 50,
          badgeLabel: 'Completada',
          badgeVariant: EvalBadgeVariant.primary,
          filter: MyExamsFilter.completed,
        ),
      ];
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  _FilterHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.child,
  });

  @override
  final double minExtent;
  @override
  final double maxExtent;
  final Widget child;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

enum MyExamsFilter {
  all('Todas'),
  pending('Pendientes'),
  inProgress('En curso'),
  completed('Completadas'),
  upcoming('Próximas');

  const MyExamsFilter(this.label);
  final String label;
}

class MyExamItem {
  const MyExamItem({
    required this.examName,
    required this.group,
    required this.teacher,
    required this.dateText,
    required this.durationMinutes,
    required this.badgeLabel,
    required this.badgeVariant,
    required this.filter,
  });

  final String examName;
  final String group;
  final String teacher;
  final String dateText;
  final int durationMinutes;
  final String badgeLabel;
  final EvalBadgeVariant badgeVariant;
  final MyExamsFilter filter;
}
