import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/blood_sugar_status.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/paper_card.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/blood_sugar_entry.dart';
import '../providers/blood_sugar_providers.dart';
import 'components/blood_sugar_value_badge.dart';

const _mealLabels = {
  'fasting': 'Lúc đói',
  'before_meal': 'Trước ăn',
  'after_meal': 'Sau ăn',
  'bedtime': 'Trước ngủ',
};

const _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

class BloodSugarDiaryScreen extends ConsumerWidget {
  const BloodSugarDiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries7 = ref.watch(bloodSugarEntriesProvider(7));
    final entries30 = ref.watch(bloodSugarEntriesProvider(30));
    final insight = ref.watch(chartInsightProvider);
    final target = ref.watch(bloodSugarTargetProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nhật ký đường huyết',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: AppColors.primary)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/diary/add'),
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
      body: entries7.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(
          message: 'Không tải được dữ liệu.',
          onRetry: () => ref.invalidate(bloodSugarEntriesProvider),
        ),
        data: (week) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Chart card
              Transform.rotate(
                angle: -0.5 * 3.14159 / 180,
                child: PaperCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📈 Xu hướng 7 ngày',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 160,
                        child: week.isEmpty
                            ? const Center(child: Text('Chưa có dữ liệu'))
                            : _TrendChart(
                                entries: week,
                                targetMin: target?.min ?? 100,
                                targetMax: target?.max ?? 126,
                              ),
                      ),
                      if (insight != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.08),
                            border: Border(
                              left: BorderSide(
                                  color: AppColors.error, width: 4),
                            ),
                          ),
                          child: Text(
                            '⚠ $insight',
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // History list
              entries30.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) => const SizedBox.shrink(),
                data: (all) => _HistoryList(
                  entries: all,
                  targetMin: target?.min ?? 100,
                  targetMax: target?.max ?? 126,
                  onDelete: (id) async {
                    await ref
                        .read(bloodSugarRepoProvider)
                        .deleteEntry(id);
                    ref.invalidate(bloodSugarEntriesProvider);
                    ref.invalidate(latestEntryProvider);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  const _TrendChart({
    required this.entries,
    required this.targetMin,
    required this.targetMax,
  });

  final List<BloodSugarEntry> entries;
  final double targetMin;
  final double targetMax;

  @override
  Widget build(BuildContext context) {
    final sorted = [...entries]
      ..sort((a, b) => a.measuredAt.compareTo(b.measuredAt));

    final normalSpots = <FlSpot>[];
    final abnormalSpots = <FlSpot>[];

    for (var i = 0; i < sorted.length; i++) {
      final e = sorted[i];
      final spot = FlSpot(i.toDouble(), e.value);
      final s = getStatus(e.value, targetMin: targetMin, targetMax: targetMax);
      if (s == BloodSugarStatus.normal || s == BloodSugarStatus.prediabetes) {
        normalSpots.add(spot);
      } else {
        abnormalSpots.add(spot);
      }
    }

    return LineChart(
      LineChartData(
        minY: 40,
        maxY: 300,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                if (idx < 0 || idx >= sorted.length) return const SizedBox.shrink();
                final day = sorted[idx].measuredAt.weekday;
                return Text(_dayLabels[day - 1],
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(y: targetMin, color: AppColors.outline, strokeWidth: 1, dashArray: [4, 4]),
            HorizontalLine(y: targetMax, color: AppColors.error.withOpacity(0.4), strokeWidth: 1, dashArray: [4, 4]),
          ],
        ),
        lineBarsData: [
          if (normalSpots.isNotEmpty)
            LineChartBarData(
              spots: normalSpots,
              color: AppColors.bsNormal,
              barWidth: 2,
              dotData: FlDotData(
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.bsNormal,
                ),
              ),
            ),
          if (abnormalSpots.isNotEmpty)
            LineChartBarData(
              spots: abnormalSpots,
              color: AppColors.error,
              barWidth: 2,
              dotData: FlDotData(
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 5,
                  color: AppColors.error,
                  strokeWidth: 2,
                  strokeColor: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatefulWidget {
  const _HistoryList({
    required this.entries,
    required this.targetMin,
    required this.targetMax,
    required this.onDelete,
  });

  final List<BloodSugarEntry> entries;
  final double targetMin;
  final double targetMax;
  final Future<void> Function(int id) onDelete;

  @override
  State<_HistoryList> createState() => _HistoryListState();
}

class _HistoryListState extends State<_HistoryList> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final shown = _showAll ? widget.entries : widget.entries.take(10).toList();

    if (widget.entries.isEmpty) {
      return EmptyState(
        icon: Icons.bloodtype_outlined,
        message: 'Chưa có dữ liệu đường huyết.\nNhấn + để thêm.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lịch sử đo',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary)),
        const SizedBox(height: 8),
        ...shown.map((e) => _HistoryItem(
              entry: e,
              targetMin: widget.targetMin,
              targetMax: widget.targetMax,
              onDelete: () => widget.onDelete(e.id),
            )),
        if (!_showAll && widget.entries.length > 10)
          TextButton(
            onPressed: () => setState(() => _showAll = true),
            child: const Text('Xem toàn bộ lịch sử ▼',
                style: TextStyle(color: AppColors.primary)),
          ),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.entry,
    required this.targetMin,
    required this.targetMax,
    required this.onDelete,
  });

  final BloodSugarEntry entry;
  final double targetMin;
  final double targetMax;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final s = getStatus(entry.value,
        targetMin: targetMin, targetMax: targetMax);
    final isAbnormal =
        s == BloodSugarStatus.low || s == BloodSugarStatus.high;
    final date = DateFormat('dd/MM').format(entry.measuredAt);
    final time = DateFormat('HH:mm').format(entry.measuredAt);
    final meal = _mealLabels[entry.mealContext] ?? entry.mealContext;

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isAbnormal
              ? AppColors.error.withOpacity(0.05)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isAbnormal
                ? AppColors.error.withOpacity(0.3)
                : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 42,
              child: Column(
                children: [
                  Text(date,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface)),
                  Text(time,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal,
                      style: const TextStyle(color: AppColors.onSurfaceVariant,
                          fontSize: 13)),
                  Text(statusLabel(s),
                      style: TextStyle(
                          color: statusColor(s),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            BloodSugarValueBadge(value: entry.value, status: s),
            const SizedBox(width: 4),
            const Text(' mg/dL',
                style: TextStyle(
                    fontSize: 11, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
