import 'package:flutter/material.dart';

class CountUpText extends StatelessWidget {
  const CountUpText({
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.decimals = 0,
    this.duration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeOut,
    this.style,
    super.key,
  });

  final double value;
  final String prefix;
  final String suffix;
  final int decimals;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, _) {
        final formatted = animatedValue.toStringAsFixed(decimals);
        return Text('$prefix$formatted$suffix', style: style);
      },
    );
  }
}
