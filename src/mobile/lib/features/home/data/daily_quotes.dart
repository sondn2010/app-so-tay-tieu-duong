const kDailyQuotes = [
  'Mỗi bữa ăn lành mạnh là một bước tiến gần hơn đến sự cân bằng.',
  'Một bước chân mỗi ngày, sức khỏe sẽ đến.',
  'Kiểm soát đường huyết hôm nay là bảo vệ tương lai của bạn.',
  'Sức khỏe không phải may mắn — đó là kết quả của những lựa chọn hàng ngày.',
  'Uống thuốc đúng giờ là yêu thương bản thân.',
  'Vận động nhẹ nhàng mỗi ngày, cơ thể sẽ cảm ơn bạn.',
  'Đường huyết ổn định là nền tảng của cuộc sống vui khỏe.',
  'Mỗi con số bạn theo dõi là một hành động yêu thương bản thân.',
  'Kiên nhẫn với bản thân — thay đổi tốt cần thời gian.',
  'Ăn đúng, ngủ đủ, vận động đều — ba chìa khóa vàng.',
  'Nhật ký sức khỏe hôm nay giúp bác sĩ hỗ trợ bạn tốt hơn ngày mai.',
  'Hãy tự hào về mỗi quyết định sống lành mạnh bạn đã chọn.',
  'Nước là người bạn tốt nhất của cơ thể bạn.',
  'Stress ảnh hưởng đến đường huyết — hãy dành 5 phút thở sâu hôm nay.',
  'Chia nhỏ bữa ăn giúp đường huyết ổn định hơn.',
  'Giấc ngủ ngon là liều thuốc miễn phí tốt nhất.',
  'Yêu bản thân đủ để chăm sóc sức khỏe mỗi ngày.',
  'Mỗi bước đi là thuốc chữa bệnh tuyệt vời.',
  'Lựa chọn thực phẩm khôn ngoan hôm nay, sức khỏe vững chắc ngày mai.',
  'Theo dõi không phải để lo lắng, mà để hiểu rõ cơ thể mình hơn.',
  'Một ly nước trước bữa ăn giúp kiểm soát lượng thức ăn tốt hơn.',
  'Hạnh phúc bắt đầu từ một cơ thể khỏe mạnh.',
  'Rau xanh mỗi ngày — đơn giản nhưng hiệu quả.',
  'Bạn không cần hoàn hảo, chỉ cần tiến bộ mỗi ngày.',
  'Thuốc đúng liều, đúng giờ — sức mạnh trong kỷ luật nhỏ.',
  'Cơ thể bạn xứng đáng được chăm sóc tốt nhất.',
  'Mỗi ngày bình thường là một ngày thắng lợi.',
  'Chia sẻ hành trình sức khỏe với người thân sẽ giúp bạn vững bước hơn.',
  'Từng bước nhỏ tích lũy thành hành trình vĩ đại.',
  'Hôm nay bạn chọn sức khỏe — tương lai sẽ cảm ơn bạn.',
];

String getDailyQuote() {
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year)).inDays;
  return kDailyQuotes[dayOfYear % kDailyQuotes.length];
}

String greetByTime() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Chào buổi sáng';
  if (h < 18) return 'Chào buổi chiều';
  return 'Chào buổi tối';
}
