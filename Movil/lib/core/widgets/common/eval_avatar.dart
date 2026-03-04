import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

enum EvalAvatarSize { sm, md, lg, xl }

class EvalAvatar extends StatelessWidget {
  const EvalAvatar({
    this.imageUrl,
    this.name,
    this.size = EvalAvatarSize.md,
    this.isOnline,
    this.customSize,
    super.key,
  });

  final String? imageUrl;
  final String? name;
  final EvalAvatarSize size;
  final bool? isOnline;
  final double? customSize;

  double get _resolvedSize {
    if (customSize != null) {
      return customSize!;
    }
    return switch (size) {
      EvalAvatarSize.sm => 32,
      EvalAvatarSize.md => 40,
      EvalAvatarSize.lg => 56,
      EvalAvatarSize.xl => 72,
    };
  }

  String get _initials {
    final value = (name ?? '').trim();
    if (value.isEmpty) {
      return 'EP';
    }
    final parts = value.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final sizeValue = _resolvedSize;
    final dotSize = 8.0;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: 'Avatar ${name ?? ''}'.trim(),
      child: SizedBox(
        width: sizeValue,
        height: sizeValue,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: sizeValue,
              height: sizeValue,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
                boxShadow: AppSpacing.shadowSm,
                gradient: imageUrl == null
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl == null
                  ? Center(
                      child: Text(
                        _initials,
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.surface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Center(
                        child: Text(
                          _initials,
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.surface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
            ),
            if (isOnline != null)
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: isOnline! ? AppColors.success : AppColors.slate400,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
