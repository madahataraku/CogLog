import 'package:test/test.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';
import 'package:usecase_generate_top_advice_impl/usecase_generate_top_advice_impl.dart';

void main() {
  const parser = TopAdviceLlmResponseParserImpl();

  test('TONE と ADVICE の両行を解析する', () {
    final result = parser.parse('TONE=happy\nADVICE=よく動けた');
    expect(result.advice, 'よく動けた');
    expect(result.tone, AdviceTone.happy);
  });

  test('未知の TONE は fun にフォールバックする', () {
    final result = parser.parse('TONE=???\nADVICE=x');
    expect(result.advice, 'x');
    expect(result.tone, AdviceTone.fun);
  });

  test('ADVICE のみのとき tone は fun', () {
    final result = parser.parse('ADVICE=のみ');
    expect(result.advice, 'のみ');
    expect(result.tone, AdviceTone.fun);
  });

  test('空文字のとき advice 空・tone fun', () {
    final result = parser.parse('');
    expect(result.advice, '');
    expect(result.tone, AdviceTone.fun);
  });
}
