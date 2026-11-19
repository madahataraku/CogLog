import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

/// Swift / CocoaPods と共有する lean monolithic 取得マニフェスト。
File iosMonolithicManifestFile() {
  // flutter test はパッケージルートで実行される。
  return File(
    [
      Directory.current.path,
      'ios',
      'infra_gemma_meter_mobile',
      'Sources',
      'infra_gemma_meter_mobile',
      'ios_monolithic_download_manifest.json',
    ].join(Platform.pathSeparator),
  );
}

void main() {
  test('共有マニフェストは約 2.9 GB で chunk / video / audio / PLE を含まない', () {
    final file = iosMonolithicManifestFile();
    expect(file.existsSync(), isTrue, reason: file.path);

    final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    expect(json['repo'], 'smdesai/gemma-4-E2B-coreml');
    expect(json['revision'], 'main');

    final files = (json['files'] as List<Object?>).cast<Map<String, Object?>>();
    expect(files, hasLength(10));

    final total = files.fold<int>(
      0,
      (sum, entry) => sum + (entry['estimatedSize']! as num).toInt(),
    );
    expect(total, 2890323517);
    expect(total / 1e9, closeTo(2.89, 0.01));

    // Download + compile headroom used by native minFreeBytes.
    expect(total * 2 + 500000000, greaterThan(6e9));

    final paths = files.map((e) => e['path']! as String).toList();
    expect(
      paths,
      contains('model.mlpackage/Data/com.apple.CoreML/weights/weight.bin'),
    );
    expect(
      paths,
      contains('vision.mlpackage/Data/com.apple.CoreML/weights/weight.bin'),
    );
    expect(paths, contains('hf_model/tokenizer.json'));

    for (final path in paths) {
      expect(path.contains('chunk1'), isFalse);
      expect(path.contains('vision_video'), isFalse);
      expect(path.contains('audio.'), isFalse);
      expect(path.contains('embed_tokens_per_layer'), isFalse);
    }
  });
}
