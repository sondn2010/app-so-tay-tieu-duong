import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/blood_sugar_status.dart';
import '../../blood_sugar/providers/blood_sugar_providers.dart';
import '../../profile/providers/profile_providers.dart';

const _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

class BloodSugarMiniChart extends ConsumerWidget {
  const BloodSugarMiniChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(bloodSugarEntriesProvider(7)).valueOrNull ?? [];
    final target = ref.watch(bloodSugarTargetProvider).valueOrNull;
    final targetMin = target?.min ?? 100;
    final targetMax = target?.max ?? 126;

    if (entries.isEmpty) {
      return const SizedBox(
        height: 60,
        child: Center(
          child: Text('Chưa có dữ liệu',
              style: TextStyle(color: AppColors.outline, fontSize: 12)),
        ),
      );
    }

    final sorted = [...entries]
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));
    const minV = 60.0;
    const maxV = 250.0;

    return SizedBox(
      height: 72,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(sorted.length, (i) {
                final e = sorted[i];
                final s = getStatus(e.value,
                    targetMin: targetMin, targetMax: targetMax);
                final isAbnormal = s == BloodSugarStatus.low ||
                    s == BloodSugarStatus.high;
                final isToday = i == sorted.length - 1;
                final frac =
                    ((e.value - minV) / (maxV - minV)).clamp(0.05, 1.0);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: FractionallySizedBox(
                      heightFactor: frac,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isAbnormal
                              ? AppColors.error.withOpacity(isToday ? 1 : 0.5)
                              : AppColors.primary.withOpacity(isToday ? 1 : 0.25),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: sorted.map((e) {
              final day = e.measuredAt.weekday;
              return Expanded(
                child: Text(
                  _dayLabels[day - 1],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 9, color: AppColors.onSurfaceVariant),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
