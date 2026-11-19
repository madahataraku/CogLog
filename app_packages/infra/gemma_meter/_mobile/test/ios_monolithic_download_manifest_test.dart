import 'package:test/test.dart';

/// iOS lean monolithic 取得対象（`GemmaMeterPlugin.swift` の downloadFiles と同期）。
///
/// CoreMLLLM が monolithic 経路を選ぶよう、`chunk1` は含めない。
const iosMonolithicDownloadFiles = <(String, int)>[
  ('hf_model/config.json', 4954),
  ('hf_model/tokenizer.json', 32169626),
  ('hf_model/tokenizer_config.json', 2068),
  ('model.mlpackage/Data/com.apple.CoreML/model.mlmodel', 1381053),
  ('model.mlpackage/Data/com.apple.CoreML/weights/weight.bin', 2518622912),
  ('model.mlpackage/Manifest.json', 617),
  ('model_config.json', 401),
  ('vision.mlpackage/Data/com.apple.CoreML/model.mlmodel', 592021),
  ('vision.mlpackage/Data/com.apple.CoreML/weights/weight.bin', 337549248),
  ('vision.mlpackage/Manifest.json', 617),
];

void main() {
  test('iOS monolithic 取得は約 2.9 GB で chunk / video / audio / PLE を含まない', () {
    final total = iosMonolithicDownloadFiles.fold<int>(
      0,
      (sum, entry) => sum + entry.$2,
    );
    expect(total, 2890323517);
    expect(total / 1e9, closeTo(2.89, 0.01));

    final paths = iosMonolithicDownloadFiles.map((e) => e.$1).toList();
    expect(paths, contains('model.mlpackage/Data/com.apple.CoreML/weights/weight.bin'));
    expect(paths, contains('vision.mlpackage/Data/com.apple.CoreML/weights/weight.bin'));
    expect(paths, contains('hf_model/tokenizer.json'));

    for (final path in paths) {
      expect(path.contains('chunk1'), isFalse);
      expect(path.contains('vision_video'), isFalse);
      expect(path.contains('audio.'), isFalse);
      expect(path.contains('embed_tokens_per_layer'), isFalse);
    }
  });
}
