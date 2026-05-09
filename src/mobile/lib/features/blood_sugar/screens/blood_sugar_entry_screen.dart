import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/blood_sugar_numpad.dart';
import '../../../core/widgets/paper_card.dart';
import '../data/blood_sugar_entry.dart';
import '../data/blood_sugar_repository.dart';
import '../providers/blood_sugar_providers.dart';

const _mealContexts = [
  ('fasting', 'Lúc đói'),
  ('before_meal', 'Trước ăn'),
  ('after_meal', 'Sau ăn'),
  ('bedtime', 'Trước khi ngủ'),
];

class BloodSugarEntryScreen extends ConsumerStatefulWidget {
  const BloodSugarEntryScreen({super.key});

  @override
  ConsumerState<BloodSugarEntryScreen> createState() =>
      _BloodSugarEntryScreenState();
}

class _BloodSugarEntryScreenState
    extends ConsumerState<BloodSugarEntryScreen> {
  String _input = '';
  String _mealContext = 'fasting';

  void _onChanged(String v) => setState(() => _input = v);

  double? get _parsedValue => double.tryParse(_input);

  Future<void> _save() async {
    final raw = _parsedValue;
    if (raw == null) {
      _showError('Vui lòng nhập chỉ số đường huyết.');
      return;
    }

    final unit = ref.read(bloodSugarUnitProvider);
    final mgdl = unit == BloodSugarUnit.mmoll ? mmolToMgdl(raw) : raw;

    if (mgdl < 20 || mgdl > 600) {
      _showError('Chỉ số phải nằm trong khoảng 20–600 mg/dL.');
      return;
    }

    final entry = BloodSugarEntry()
      ..value = mgdl
      ..measuredAt = DateTime.now()
      ..mealContext = _mealContext;

    await ref.read(bloodSugarRepoProvider).addEntry(entry);

    // Persist unit preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('blood_sugar_unit', unit.name);

    ref.invalidate(bloodSugarEntriesProvider);
    ref.invalidate(latestEntryProvider);

    if (mounted) Navigator.of(context).pop();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));
  }

  @override
  Widget build(BuildContext context) {
    final unit = ref.watch(bloodSugarUnitProvider);
    final now = DateTime.now();
    final timeLabel = DateFormat('HH:mm, dd/MM/yyyy').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhập chỉ số'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: PaperCard(
          rotation: 0.2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Unit toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _UnitToggle(
                    current: unit,
                    onChanged: (u) =>
                        ref.read(bloodSugarUnitProvider.notifier).state = u,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Value display
              Center(
                child: Column(
                  children: [
                    Text(
                      _input.isEmpty ? '—' : _input,
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Divider(color: AppColors.outline, thickness: 1),
                    Text(
                      timeLabel,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Numpad
              BloodSugarNumpad(value: _input, onChanged: _onChanged),
              const SizedBox(height: 16),
              // Meal context
              DropdownButtonFormField<String>(
                value: _mealContext,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _mealContexts
                    .map(
                      (e) => DropdownMenuItem(value: e.$1, child: Text(e.$2)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _mealContext = v!),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Lưu Nhật Ký',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.current, required this.onChanged});

  final BloodSugarUnit current;
  final ValueChanged<BloodSugarUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _pill('mg/dL', BloodSugarUnit.mgdl),
        const SizedBox(width: 4),
        _pill('mmol/L', BloodSugarUnit.mmoll),
      ],
    );
  }

  Widget _pill(String label, BloodSugarUnit unit) {
    final active = current == unit;
    return GestureDetector(
      onTap: () => onChanged(unit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.onPrimary : AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
