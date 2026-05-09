import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/blood_sugar_status.dart';
import '../../../core/widgets/paper_card.dart';
import '../../blood_sugar/providers/blood_sugar_providers.dart';
import '../../medication/widgets/medication_reminder_banner.dart';
import '../../medication/providers/medication_providers.dart';
import '../../profile/data/user_profile.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/daily_quotes.dart';
import '../providers/home_providers.dart';
import '../widgets/blood_sugar_mini_chart.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final latestEntry = ref.watch(latestEntryProvider).valueOrNull;
    final target = ref.watch(bloodSugarTargetProvider).valueOrNull;
    final doseSummary = ref.watch(todayDoseSummaryProvider).valueOrNull;
    final steps = ref.watch(todayStepsProvider).valueOrNull ?? 0;
    final quote = ref.watch(dailyQuoteProvider);

    final profile = profileAsync.valueOrNull;
    final greeting = greetByTime();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _Header(profile: profile),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Welcome card
                    PaperCard(
                      rotation: 0.2,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$greeting, ${profile?.name ?? 'bạn'}! 🌿',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.onSurfaceVariant,
                                      fontStyle: FontStyle.italic),
                                ),
                                const Text(
                                  'Sức khỏe hôm nay',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.star,
                              color: AppColors.secondary, size: 28),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Blood sugar card
                    _BloodSugarCard(
                      latestValue: latestEntry?.value,
                      targetMin: target?.min ?? 100,
                      targetMax: target?.max ?? 126,
                    ),
                    const SizedBox(height: 12),
                    // Medication reminder
                    const MedicationReminderBanner(),
                    const SizedBox(height: 12),
                    // Daily summary grid
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryTile(
                            icon: '💊',
                            label: 'Đã uống',
                            value: doseSummary != null
                                ? '${doseSummary.taken}/${doseSummary.total} liều'
                                : '—',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showStepsDialog(context, ref, steps),
                            child: _SummaryTile(
                              icon: '🚶',
                              label: 'Vận động',
                              value:
                                  '${_formatSteps(steps)} bước',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Daily quote card
                    PaperCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gợi ý hôm nay',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '"$quote"',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: AppColors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}k';
    }
    return steps.toString();
  }

  Future<void> _showStepsDialog(
      BuildContext context, WidgetRef ref, int current) async {
    final ctrl = TextEditingController(text: current > 0 ? '$current' : '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cập nhật số bước'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration:
              const InputDecoration(labelText: 'Số bước hôm nay'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Lưu')),
        ],
      ),
    );
    if (confirmed != true) return;
    final steps = int.tryParse(ctrl.text);
    if (steps == null) return;
    final repo = await ref.read(stepsRepoProvider.future);
    await repo.setTodaySteps(steps);
    ref.invalidate(todayStepsProvider);
  }
}

class _Header extends StatelessWidget {
  const _Header({this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.surfaceContainerLow,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryContainer,
            backgroundImage: profile?.avatarPath != null
                ? FileImage(File(profile!.avatarPath!))
                : null,
            child: profile?.avatarPath == null
                ? const Icon(Icons.person, size: 20, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              profile?.name ?? 'Sổ Tay Tiểu Đường',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
          ),
          const Icon(Icons.lightbulb_outline, color: AppColors.secondary),
        ],
      ),
    );
  }
}

class _BloodSugarCard extends ConsumerWidget {
  const _BloodSugarCard({
    this.latestValue,
    required this.targetMin,
    required this.targetMax,
  });

  final double? latestValue;
  final double targetMin;
  final double targetMax;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = latestValue != null
        ? getStatus(latestValue!,
            targetMin: targetMin, targetMax: targetMax)
        : null;

    return PaperCard(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💧 ĐƯỜNG HUYẾT',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant)),
              const Spacer(),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel(status),
                    style: TextStyle(
                        fontSize: 11,
                        color: statusColor(status),
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                latestValue != null
                    ? '${latestValue!.round()}'
                    : '—',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: status != null
                      ? statusColor(status)
                      : AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('mg/dL',
                    style: TextStyle(
                        color: AppColors.onSurfaceVariant, fontSize: 13)),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/diary/add'),
                child: const Text('+ Thêm',
                    style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const BloodSugarMiniChart(),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.onSurfaceVariant)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                  fontSize: 15)),
        ],
      ),
    );
  }
}
