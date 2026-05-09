import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

const _faqs = [
  (
    'Chỉ số đường huyết bình thường là bao nhiêu?',
    'Khi đói: 70–99 mg/dL. Sau ăn 2 giờ: dưới 140 mg/dL. Người tiểu đường nên duy trì mục tiêu được bác sĩ đề ra.',
  ),
  (
    'Làm sao để thêm thuốc nhắc nhở?',
    'Vào Trang chủ → Nhắc nhở → Thêm thuốc. Nhập tên thuốc, liều dùng và chọn thời điểm uống.',
  ),
  (
    'Ứng dụng có lưu dữ liệu lên cloud không?',
    'Phiên bản hiện tại lưu dữ liệu hoàn toàn trên thiết bị của bạn. Tính năng đồng bộ cloud sẽ ra mắt trong phiên bản tiếp theo.',
  ),
  (
    'Cách đổi đơn vị mg/dL sang mmol/L?',
    'Vào Nhật ký → nhấn + để thêm chỉ số → nhấn nút mmol/L ở góc trên bên phải.',
  ),
  (
    'Liên hệ hỗ trợ ở đâu?',
    'Email: support@sotaytieududuong.vn. Chúng tôi phản hồi trong vòng 24 giờ.',
  ),
];

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hỗ trợ',
            style: TextStyle(color: AppColors.primary)),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        separatorBuilder: (_, __) =>
            const Divider(color: AppColors.outlineVariant),
        itemBuilder: (_, i) => ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(
            _faqs[i].$1,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _faqs[i].$2,
                style: const TextStyle(
                    color: AppColors.onSurfaceVariant, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
