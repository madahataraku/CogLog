import 'package:riverpod/legacy.dart';

/// インポート成功後に各画面を再読込させる世代カウンタ。
///
/// Example:
/// ```dart
/// ref.read(appDataImportRefreshProvider.notifier).state++;
/// ```
final appDataImportRefreshProvider = StateProvider<int>((ref) => 0);
