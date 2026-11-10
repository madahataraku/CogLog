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

  test('toString が型名のみのときは Type: null にする', () {
    expect(formatExceptionDetail(_Empty()), '_Empty: null');
  });

  test('cause 連鎖を残す', () {
    final error = _Chained(
      'outer',
      cause: _Chained('mid', cause: _Named('inner')),
    );
    expect(
      formatExceptionDetail(error),
      '_Chained: outer | cause: _Chained: mid | cause: _Named: inner',
    );
  });

  test('cause 連鎖は深さ 5 で打ち切る', () {
    Object chain = _Named('leaf');
    for (var i = 0; i < 8; i++) {
      chain = _Chained('n$i', cause: chain);
    }
    final detail = formatExceptionDetail(chain);
    expect(detail.split(' | cause: '), hasLength(6));
    expect(detail, isNot(contains('_Named: leaf')));
  });

  test('長い詳細は最大長で切り詰める', () {
    final detail = formatExceptionDetail(_Named('x' * 5000));
    expect(detail.length, formatExceptionDetailMaxLength + 1);
    expect(detail.endsWith('…'), isTrue);
  });
}

final class _Named implements Exception {
  _Named(this.detail);

  final String detail;

  @override
  String toString() => '_Named: $detail';
}

final class _Empty implements Exception {
  @override
  String toString() => '_Empty';
}

final class _Chained implements Exception, ExceptionWithCause {
  _Chained(this.detail, {this.cause});

  final String detail;

  @override
  final Object? cause;

  @override
  String toString() => '_Chained: $detail';
}
