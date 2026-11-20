import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

/// Swift / CocoaPods と共有する iOS Core ML 取得マニフェスト（ファイル名は歴史的）。
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
  test('共有マニフェストは n1024 chunk 構成で約 4.3 GB（video/audio なし）', () {
    final file = iosMonolithicManifestFile();
    expect(file.existsSync(), isTrue, reason: file.path);

    final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    expect(json['repo'], 'mlboydaisuke/gemma-4-E2B-coreml');
    expect(json['revision'], 'n1024');

    final files = (json['files'] as List<Object?>).cast<Map<String, Object?>>();
    expect(files, hasLength(56));

    final total = files.fold<int>(
      0,
      (sum, entry) => sum + (entry['estimatedSize']! as num).toInt(),
    );
    expect(total, 4305418292);
    expect(total / 1e9, closeTo(4.31, 0.01));

    // Download + compile headroom used by native minFreeBytes.
    expect(total * 2 + 500000000, greaterThan(9e9));

    final paths = files.map((e) => e['path']! as String).toList();
    expect(paths, contains('chunk1.mlmodelc/weights/weight.bin'));
    expect(paths, contains('prefill_chunk1.mlmodelc/model.mil'));
    expect(paths, contains('vision.mlmodelc/weights/weight.bin'));
    expect(paths, contains('embed_tokens_per_layer_q8.bin'));
    expect(paths, contains('hf_model/tokenizer.json'));

    // Prefill weights are hardlinked from decode chunks after download.
    expect(
      paths.any(
        (p) => p.contains('prefill_chunk') && p.endsWith('weights/weight.bin'),
      ),
      isFalse,
    );

    final remotes = files
        .map((e) => e['remotePath'] as String?)
        .whereType<String>()
        .toList();
    expect(remotes, contains('swa/chunk1.mlmodelc/weights/weight.bin'));
    expect(remotes, contains('prefill/chunk1.mlmodelc/model.mil'));

    for (final path in paths) {
      expect(path.contains('vision_video'), isFalse);
      expect(path.contains('audio.'), isFalse);
      expect(path.contains('model.mlpackage'), isFalse);
    }
  });
}
