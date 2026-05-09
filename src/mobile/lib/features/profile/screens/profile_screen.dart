import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/isar_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../data/avatar_service.dart';
import '../data/user_profile.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => const Center(child: Text('Lỗi tải hồ sơ')),
        data: (profile) => _ProfileBody(profile: profile),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});

  final UserProfile profile;

  Future<void> _signOut(BuildContext ctx, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Toàn bộ dữ liệu sẽ bị xóa. Bạn có chắc không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa & Đăng xuất',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final db = ref.read(isarProvider);
    await db.writeTxn(() => db.clear());
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (ctx.mounted) ctx.go('/onboarding');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primaryContainer,
                  backgroundImage: profile.avatarPath != null
                      ? FileImage(File(profile.avatarPath!))
                      : null,
                  child: profile.avatarPath == null
                      ? const Icon(Icons.person, size: 48, color: AppColors.primary)
                      : null,
                ),
                Transform.rotate(
                  angle: -0.21,
                  child: GestureDetector(
                    onTap: () async {
                      final path = await AvatarService.pickAndSave();
                      if (path == null) return;
                      final repo = ref.read(profileRepoProvider);
                      final p = await repo.getOrCreate();
                      p.avatarPath = path;
                      await repo.saveProfile(p);
                      ref.invalidate(userProfileProvider);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              profile.name,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface),
            ),
            Text(
              'Thành viên từ: ${_memberSince(profile)}',
              style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13),
            ),
            const SizedBox(height: 20),
            // Health info
            Align(
              alignment: Alignment.centerLeft,
              child: const Text('🏥 Thông tin sức khoẻ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.onSurface)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _InfoCard(label: 'Loại bệnh', value: _diabetesLabel(profile.diabetesType))),
                const SizedBox(width: 8),
                Expanded(child: _InfoCard(label: 'Mục tiêu', value: '${profile.targetMin.round()}–${profile.targetMax.round()} mg/dL')),
              ],
            ),
            const SizedBox(height: 8),
            _InfoCard(
              label: 'Chỉ số cơ thể',
              value: '${profile.heightCm.round()} cm  •  ${profile.weightKg.round()} kg',
              wide: true,
            ),
            const SizedBox(height: 20),
            // Settings menu
            Align(
              alignment: Alignment.centerLeft,
              child: const Text('⚙ Cài đặt tài khoản',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.onSurface)),
            ),
            const SizedBox(height: 8),
            _MenuItem(label: 'Thông tin cá nhân', onTap: () => context.push('/profile/edit')),
            const Divider(color: AppColors.outlineVariant),
            _MenuItem(label: 'Nhắc nhở', onTap: () => context.push('/home/medication')),
            const Divider(color: AppColors.outlineVariant),
            _MenuItem(label: 'Đồng bộ dữ liệu', onTap: () => context.push('/profile/sync')),
            const Divider(color: AppColors.outlineVariant),
            _MenuItem(label: 'Hỗ trợ', onTap: () => context.push('/profile/help')),
            const SizedBox(height: 24),
            // Sign out
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _signOut(context, ref),
                child: const Text('Đăng xuất',
                    style: TextStyle(
                        color: AppColors.error, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _memberSince(UserProfile p) {
    if (p.dateOfBirth != null) {
      final d = p.dateOfBirth!;
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    }
    return 'N/A';
  }

  String _diabetesLabel(String type) => switch (type) {
        'type1' => 'Type 1',
        'type2' => 'Type 2',
        'prediabetes' => 'Tiền tiểu đường',
        _ => type,
      };
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value, this.wide = false});

  final String label;
  final String value;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.onSurface)),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(color: AppColors.onSurface))),
            const Icon(Icons.chevron_right, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}
