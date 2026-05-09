import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.child,
    this.rotation = 0.0,
    this.padding = const EdgeInsets.all(16),
    this.color,
  });

  final Widget child;
  final double rotation;
  final EdgeInsets padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outline.withOpacity(0.4), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3335675B),
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );

    if (rotation == 0.0) return card;
    return Transform.rotate(angle: rotation * 3.14159 / 180, child: card);
  }
}
