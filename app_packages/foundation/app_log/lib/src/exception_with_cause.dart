/// [formatExceptionDetail] が辿る cause を持つ例外向け。
///
/// Example:
/// ```dart
/// class MyError implements Exception, ExceptionWithCause {
///   MyError(this.message, {this.cause});
///   final String message;
///   @override
///   final Object? cause;
/// }
/// ```
abstract interface class ExceptionWithCause {
  /// 直前の原因。無ければ null。
  Object? get cause;
}
