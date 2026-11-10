import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:test/test.dart';

/// [formatExceptionDetail] の整形と切り詰めを検証する。
///
/// Example:
/// ```dart
/// main();
/// ```
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
    expect(detail.length, formatExceptionDetailMaxLength);
    expect(detail.endsWith('…'), isTrue);
  });
}

/// toString に型名を含む例外。
///
/// Example:
/// ```dart
/// _Named('detail');
/// ```
final class _Named implements Exception {
  /// [detail] を持つ。
  ///
  /// Example:
  /// ```dart
  /// _Named('detail');
  /// ```
  _Named(this.detail);

  /// 表示する本文。
  final String detail;

  /// 型名付きの文字列を返す。
  ///
  /// Example:
  /// ```dart
  /// _Named('detail').toString();
  /// ```
  @override
  String toString() => '_Named: $detail';
}

/// toString が型名だけの例外。
///
/// Example:
/// ```dart
/// _Empty();
/// ```
final class _Empty implements Exception {
  /// 空の例外を作る。
  ///
  /// Example:
  /// ```dart
  /// _Empty();
  /// ```
  _Empty();

  /// 型名だけを返す。
  ///
  /// Example:
  /// ```dart
  /// _Empty().toString();
  /// ```
  @override
  String toString() => '_Empty';
}

/// [ExceptionWithCause] を持つ連鎖用例外。
///
/// Example:
/// ```dart
/// _Chained('outer', cause: _Named('inner'));
/// ```
final class _Chained implements Exception, ExceptionWithCause {
  /// [detail] と任意の [cause] を持つ。
  ///
  /// Example:
  /// ```dart
  /// _Chained('outer', cause: _Named('inner'));
  /// ```
  _Chained(this.detail, {this.cause});

  /// 表示する本文。
  final String detail;

  /// 直前の原因。
  @override
  final Object? cause;

  /// 型名付きの文字列を返す。
  ///
  /// Example:
  /// ```dart
  /// _Chained('outer').toString();
  /// ```
  @override
  String toString() => '_Chained: $detail';
}
