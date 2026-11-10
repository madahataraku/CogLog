import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:test/test.dart';

void main() {
  test('型名とメッセージを結合する', () {
    expect(
      formatExceptionDetail(StateError('boom')),
      'StateError: Bad state: boom',
    );
  });

  test('toString に型名があるときは重複しない', () {
    expect(formatExceptionDetail(_Named('detail')), '_Named: detail');
  });
}

final class _Named implements Exception {
  _Named(this.detail);

  final String detail;

  @override
  String toString() => '_Named: $detail';
}
