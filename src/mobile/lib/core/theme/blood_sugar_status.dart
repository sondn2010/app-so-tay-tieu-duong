import 'package:flutter/material.dart';

import 'app_theme.dart';

enum BloodSugarStatus { low, normal, prediabetes, high }

// Accepts explicit thresholds so callers can pass user's custom target range
BloodSugarStatus getStatus(
  double value, {
  double low = 70,
  double targetMin = 100,
  double targetMax = 126,
}) {
  if (value < low) return BloodSugarStatus.low;
  if (value < targetMin) return BloodSugarStatus.normal;
  if (value < targetMax) return BloodSugarStatus.prediabetes;
  return BloodSugarStatus.high;
}

Color statusColor(BloodSugarStatus s) => switch (s) {
      BloodSugarStatus.low => AppColors.bsLow,
      BloodSugarStatus.normal => AppColors.bsNormal,
      BloodSugarStatus.prediabetes => AppColors.bsPrediabetes,
      BloodSugarStatus.high => AppColors.bsHigh,
    };

String statusLabel(BloodSugarStatus s) => switch (s) {
      BloodSugarStatus.low => 'Hạ đường huyết',
      BloodSugarStatus.normal => 'Bình thường',
      BloodSugarStatus.prediabetes => 'Tiền tiểu đường',
      BloodSugarStatus.high => 'Cao',
    };
