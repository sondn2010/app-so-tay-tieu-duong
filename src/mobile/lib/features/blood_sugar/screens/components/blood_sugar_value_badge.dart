import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/blood_sugar_status.dart';

class BloodSugarValueBadge extends StatelessWidget {
  const BloodSugarValueBadge({
    super.key,
    required this.value,
    required this.status,
    this.fontSize = 18,
  });

  final double value;
  final BloodSugarStatus status;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final isAbnormal =
        status == BloodSugarStatus.low || status == BloodSugarStatus.high;
    final color = statusColor(status);

    final text = Text(
      '${value.round()}',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );

    if (!isAbnormal) return text;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.error, width: 2.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: text,
      ),
    );
  }
}
