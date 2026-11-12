/// 端末ローカルの全文日時。
///
/// [languageCode] が `ja` のときだけ日本語形式。それ以外は en アメリカ形式。
///
/// Example:
/// ```dart
/// formatFullLocalDateTime(
///   DateTime(2026, 5, 18, 12, 33, 21),
///   languageCode: 'ja',
/// );
/// ```
String formatFullLocalDateTime(DateTime value, {required String languageCode}) {
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  if (languageCode == 'ja') {
    return '${local.year}年${two(local.month)}月${two(local.day)}日 '
        '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[local.month - 1]} ${local.day}, ${local.year}, '
      '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
}
