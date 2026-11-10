import 'exception_with_cause.dart';

/// 診断用例外文字列の最大長。ログとデバッグ画面が同じ上限を使う。
const int formatExceptionDetailMaxLength = 2000;

/// [error] の実行時型名とメッセージ、cause 連鎖を診断用文字列にする。
///
/// 出力は [formatExceptionDetailMaxLength] 文字で切り詰める。
///
/// Example:
/// ```dart
/// formatExceptionDetail(StateError('boom'));
/// ```
String formatExceptionDetail(Object error) {
  final buffer = StringBuffer(_one(error));
  Object? cause = _causeOf(error);
  var depth = 0;
  while (cause != null && depth < 5) {
    buffer
      ..write(' | cause: ')
      ..write(_one(cause));
    cause = _causeOf(cause);
    depth += 1;
  }
  final detail = buffer.toString();
  if (detail.length <= formatExceptionDetailMaxLength) {
    return detail;
  }
  return '${detail.substring(0, formatExceptionDetailMaxLength - 1)}…';
}

String _one(Object error) {
  final typeName = error.runtimeType.toString();
  final text = error.toString();
  if (text.isEmpty || text == typeName) {
    return '$typeName: null';
  }
  if (text.startsWith(typeName)) {
    return text;
  }
  return '$typeName: $text';
}

Object? _causeOf(Object error) {
  if (error is ExceptionWithCause) {
    return error.cause;
  }
  return null;
}
