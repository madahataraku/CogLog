import 'dart:io';

import 'package:test/test.dart';

/// Android LiteRT-LM engine wiring must stay aligned with iOS / docs.
void main() {
  test('Android GemmaMeterPlugin uses GPU main/vision and MTP on', () {
    final file = File(
      [
        Directory.current.path,
        'android',
        'src',
        'main',
        'kotlin',
        'io',
        'github',
        'madahataraku',
        'coglog',
        'gemma_meter',
        'GemmaMeterPlugin.kt',
      ].join(Platform.pathSeparator),
    );
    expect(file.existsSync(), isTrue, reason: file.path);
    final source = file.readAsStringSync();

    expect(source, contains('Backend.GPU()'));
    expect(source, contains('visionBackend = Backend.GPU()'));
    expect(source, contains('SpeculativeDecodingMode.ON'));
    expect(source, contains('"backend" to "gpu"'));
    expect(source, contains('"visionBackend" to "gpu"'));
    expect(source, isNot(contains('Backend.CPU()')));
  });
}
