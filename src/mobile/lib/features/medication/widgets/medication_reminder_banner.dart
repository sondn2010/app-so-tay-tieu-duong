import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_database.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/medication_notification_sync.dart';
import '../providers/medication_providers.dart';

const _slotLabels = {
  'morning': 'buổi sáng',
  'noon': 'buổi trưa',
  'evening': 'buổi tối',
  'night': 'trước khi ngủ',
};

class MedicationReminderBanner extends ConsumerWidget {
  const MedicationReminderBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = ref.watch(nextPendingDoseProvider);

    return next.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (pending) {
        if (pending.med == null) return const SizedBox.shrink();
        final med = pending.med!;
        final slotLabel = _slotLabels[pending.slot] ?? pending.slot!;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              const Text('💊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nhắc nhở thuốc',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Uống ${med.name} ${med.dosage} $slotLabel',
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () async {
                  await ref
                      .read(doseLogRepoProvider)
                      .markDone(med.id, pending.slot!);
                  final db = ref.read(isarProvider);
                  await syncMedicationNotifications(db);
                  ref.invalidate(nextPendingDoseProvider);
                  ref.invalidate(todayDoseSummaryProvider);
                },
                child: const Text('XONG',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }
}
