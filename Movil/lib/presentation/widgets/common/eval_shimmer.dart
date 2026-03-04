import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class EvalShimmer extends StatelessWidget {
  const EvalShimmer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.slate200,
      highlightColor: AppColors.slate100,
      period: const Duration(milliseconds: 1200),
      child: child,
    );
  }
}

class ShimmerLine extends StatelessWidget {
  const ShimmerLine({
    required this.width,
    required this.height,
    this.radius = AppSpacing.xs,
    super.key,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return EvalShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.slate200,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return EvalShimmer(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.slate200,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard(
      {required this.height, this.width = double.infinity, super.key});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return EvalShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.slate200,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }
}
