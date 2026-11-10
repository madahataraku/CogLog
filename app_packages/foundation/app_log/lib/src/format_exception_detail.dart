/// [error] の実行時型名とメッセージ、cause 連鎖を診断用文字列にする。
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
  return buffer.toString();
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
  try {
    final dynamic value = error;
    final cause = value.cause;
    if (cause is Object) {
      return cause;
    }
  } on Object {
    // cause を持たない型は無視する。
  }
  return null;
}
