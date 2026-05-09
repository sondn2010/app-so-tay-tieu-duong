import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_database.dart';
import '../../../core/theme/app_theme.dart';
import '../data/medication.dart';
import '../providers/medication_notification_sync.dart';
import '../providers/medication_providers.dart';

const _scheduleOptions = [
  ('morning', 'Sáng'),
  ('noon', 'Trưa'),
  ('evening', 'Tối'),
  ('night', 'Trước ngủ'),
];

class MedicationFormScreen extends ConsumerStatefulWidget {
  const MedicationFormScreen({super.key, this.medicationId});

  final int? medicationId;

  @override
  ConsumerState<MedicationFormScreen> createState() =>
      _MedicationFormScreenState();
}

class _MedicationFormScreenState
    extends ConsumerState<MedicationFormScreen> {
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _selectedSlots = <String>{};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.medicationId != null) _loadExisting();
  }

  Future<void> _loadExisting() async {
    final db = ref.read(isarProvider);
    final med = await db.medications.get(widget.medicationId!);
    if (med != null) {
      _nameCtrl.text = med.name;
      _dosageCtrl.text = med.dosage;
      setState(() => _selectedSlots.addAll(med.schedule));
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên thuốc')),
      );
      return;
    }
    if (_selectedSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một thời điểm')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final repo = ref.read(medicationRepoProvider);

    final med = Medication()
      ..name = _nameCtrl.text.trim()
      ..dosage = _dosageCtrl.text.trim()
      ..schedule = _selectedSlots.toList()
      ..isActive = true;

    if (widget.medicationId != null) {
      med.id = widget.medicationId!;
    }

    await repo.updateMedication(med);
    await syncMedicationNotifications(ref.read(isarProvider));
    ref.invalidate(activeMedicationsProvider);
    ref.invalidate(allMedicationsProvider);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.medicationId != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa thuốc' : 'Thêm thuốc',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.primary)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Tên thuốc',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dosageCtrl,
              decoration: const InputDecoration(
                labelText: 'Liều dùng (VD: 500mg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Thời điểm uống',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _scheduleOptions.map((opt) {
                final selected = _selectedSlots.contains(opt.$1);
                return FilterChip(
                  label: Text(opt.$2),
                  selected: selected,
                  selectedColor: AppColors.primaryContainer,
                  checkmarkColor: AppColors.primary,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _selectedSlots.add(opt.$1);
                    } else {
                      _selectedSlots.remove(opt.$1);
                    }
                  }),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Lưu thuốc',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
