import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/isar_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/medication_notification_sync.dart';
import '../providers/medication_providers.dart';

const _slotChips = {
  'morning': 'Sáng',
  'noon': 'Trưa',
  'evening': 'Tối',
  'night': 'Trước ngủ',
};

class MedicationListScreen extends ConsumerWidget {
  const MedicationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meds = ref.watch(allMedicationsProvider);
    final loggedKeys = ref.watch(todayLoggedKeysProvider).valueOrNull ?? {};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thuốc của tôi',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.primary)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/home/medication/add'),
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
      body: meds.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => const Center(child: Text('Lỗi tải dữ liệu')),
        data: (list) => list.isEmpty
            ? EmptyState(
                icon: Icons.medication_outlined,
                message: 'Chưa có thuốc nào.\nNhấn + để thêm.',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (ctx, i) {
                  final med = list[i];
                  return Dismissible(
                    key: ValueKey(med.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: AppColors.error,
                      child:
                          const Icon(Icons.delete_outline, color: Colors.white),
                    ),
                    confirmDismiss: (_) => showDialog<bool>(
                      context: ctx,
                      builder: (_) => AlertDialog(
                        title: const Text('Xóa thuốc?'),
                        content: Text('Xóa "${med.name}" khỏi danh sách?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Hủy')),
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Xóa',
                                  style: TextStyle(color: AppColors.error))),
                        ],
                      ),
                    ),
                    onDismissed: (_) async {
                      await ref
                          .read(medicationRepoProvider)
                          .deleteMedication(med.id);
                      await syncMedicationNotifications(
                          ref.read(isarProvider));
                      ref.invalidate(allMedicationsProvider);
                      ref.invalidate(activeMedicationsProvider);
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: AppColors.surfaceContainerLow,
                      child: ListTile(
                        leading: const Icon(Icons.medication,
                            color: AppColors.primary),
                        title: Text(med.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(med.dosage,
                                style: const TextStyle(
                                    color: AppColors.onSurfaceVariant)),
                            Wrap(
                              spacing: 4,
                              children: med.schedule.map((s) {
                                final key = '${med.id}_$s';
                                final done = loggedKeys.contains(key);
                                return Chip(
                                  label: Text(_slotChips[s] ?? s),
                                  labelStyle: TextStyle(
                                    fontSize: 11,
                                    color: done
                                        ? AppColors.onPrimary
                                        : AppColors.primary,
                                  ),
                                  backgroundColor: done
                                      ? AppColors.primaryContainer
                                      : AppColors.surfaceContainer,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined,
                              color: AppColors.primary),
                          onPressed: () =>
                              context.push('/home/medication/${med.id}'),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
