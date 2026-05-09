import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class DataSyncScreen extends StatelessWidget {
  const DataSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đồng bộ dữ liệu',
            style: TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sync, size: 64, color: AppColors.outline),
            SizedBox(height: 16),
            Text(
              'Tính năng sắp ra mắt',
              style: TextStyle(
                  fontSize: 18,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
