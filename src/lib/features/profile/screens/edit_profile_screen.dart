import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/profile_providers.dart';

const _diabetesTypes = [
  ('type1', 'Tiểu đường Type 1'),
  ('type2', 'Tiểu đường Type 2'),
  ('prediabetes', 'Tiền tiểu đường'),
];

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String _diabetesType = 'type2';
  RangeValues _targetRange = const RangeValues(70, 130);
  bool _loaded = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _loadProfile() {
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile != null && !_loaded) {
      _nameCtrl.text = profile.name;
      _heightCtrl.text =
          profile.heightCm > 0 ? profile.heightCm.toString() : '';
      _weightCtrl.text =
          profile.weightKg > 0 ? profile.weightKg.toString() : '';
      _diabetesType = profile.diabetesType;
      _targetRange = RangeValues(profile.targetMin, profile.targetMax);
      _loaded = true;
    }
  }

  Future<void> _save() async {
    final repo = ref.read(profileRepoProvider);
    final profile = await repo.getOrCreate();
    profile
      ..name = _nameCtrl.text.trim().isEmpty ? 'Người dùng' : _nameCtrl.text.trim()
      ..heightCm = double.tryParse(_heightCtrl.text) ?? profile.heightCm
      ..weightKg = double.tryParse(_weightCtrl.text) ?? profile.weightKg
      ..diabetesType = _diabetesType
      ..targetMin = _targetRange.start
      ..targetMax = _targetRange.end;
    await repo.saveProfile(profile);
    ref.invalidate(userProfileProvider);
    ref.invalidate(bloodSugarTargetProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.primary)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: profileAsync.when(
        loading: () => const LoadingIndicator(),
        error: (_, __) =>
            const Center(child: Text('Lỗi tải hồ sơ')),
        data: (_) {
          _loadProfile();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _diabetesType,
                  decoration: const InputDecoration(
                      labelText: 'Loại bệnh',
                      border: OutlineInputBorder()),
                  items: _diabetesTypes
                      .map((e) =>
                          DropdownMenuItem(value: e.$1, child: Text(e.$2)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _diabetesType = v!),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _heightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Chiều cao (cm)',
                            border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _weightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Cân nặng (kg)',
                            border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Mục tiêu đường huyết: '
                  '${_targetRange.start.round()}–${_targetRange.end.round()} mg/dL',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                RangeSlider(
                  values: _targetRange,
                  min: 60,
                  max: 200,
                  divisions: 28,
                  activeColor: AppColors.primary,
                  labels: RangeLabels(
                    '${_targetRange.start.round()}',
                    '${_targetRange.end.round()}',
                  ),
                  onChanged: (v) => setState(() => _targetRange = v),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _save,
                  child: const Text('Lưu thay đổi',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
