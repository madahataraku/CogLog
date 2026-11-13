import CoreML
import Flutter

/// Core ML で七セグ桁検出テンソルを返す。
///
/// 入出力名 `input` / `output` はプレースホルダ。
/// `tool/seven_segment/convert_coreml.py` 成功後の表示値に合わせて更新する。
/// モデル未同梱時は例外を投げ、Dart 側エンジンが汎用 OCR のみで完了する。
final class SevenSegmentCoreMlRunner {
  private var model: MLModel?

  /// letterbox 済み NHWC float32 を推論し、2268×15 行へ正規化する。
  func predict(inputFloat32: Data) throws -> [[Double]] {
    let expectedBytes = 192 * 192 * 3 * MemoryLayout<Float32>.size
    guard inputFloat32.count == expectedBytes else {
      throw NSError(
        domain: "seven_segment",
        code: 2,
        userInfo: [NSLocalizedDescriptionKey: "inputFloat32 length mismatch"]
      )
    }
    let loaded = try loadModel()
    let shape: [NSNumber] = [1, 192, 192, 3]
    let array = try MLMultiArray(shape: shape, dataType: .float32)
    inputFloat32.withUnsafeBytes { raw in
      let src = raw.bindMemory(to: Float32.self)
      for i in 0..<src.count {
        array[i] = NSNumber(value: src[i])
      }
    }
    // convert_coreml.md で確定するまでプレースホルダ。変換後に置換する。
    let inputName = "input"
    let provider = try MLDictionaryFeatureProvider(
      dictionary: [inputName: MLFeatureValue(multiArray: array)]
    )
    let out = try loaded.prediction(from: provider)
    let outputName = "output"
    guard let multi = out.featureValue(for: outputName)?.multiArrayValue else {
      throw NSError(
        domain: "seven_segment",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "output multiarray missing"]
      )
    }
    return Self.flattenToRows(multi)
  }

  private func loadModel() throws -> MLModel {
    if let model {
      return model
    }
    let bundle = Bundle(for: SevenSegmentCoreMlRunner.self)
    let url =
      bundle.url(forResource: "DigitalMeterElectricity192", withExtension: "mlmodelc")
      ?? bundle.url(forResource: "DigitalMeterElectricity192", withExtension: "mlpackage")
    guard let url else {
      throw NSError(
        domain: "seven_segment",
        code: 3,
        userInfo: [
          NSLocalizedDescriptionKey:
            "DigitalMeterElectricity192 missing from bundle; "
            + "generate on macOS via tool/seven_segment/convert_coreml.md",
        ]
      )
    }
    let loaded = try MLModel(contentsOf: url)
    model = loaded
    return loaded
  }

  private static func flattenToRows(_ multi: MLMultiArray) -> [[Double]] {
    let shape = multi.shape.map { $0.intValue }
    let rowCount: Int
    let colCount = 15
    if shape.count == 3, shape[0] == 1, shape[1] == 2268, shape[2] == 15 {
      rowCount = 2268
    } else if shape.count == 2, shape[0] == 2268, shape[1] == 15 {
      rowCount = 2268
    } else {
      return []
    }
    var rows = [[Double]](repeating: [], count: rowCount)
    for r in 0..<rowCount {
      rows[r] = [Double](repeating: 0, count: colCount)
      for c in 0..<colCount {
        // stride パディングがあっても座標キーで読む（論理 count 比較はしない）。
        let key: [NSNumber]
        if shape.count == 3 {
          key = [0, r, c].map { NSNumber(value: $0) }
        } else {
          key = [r, c].map { NSNumber(value: $0) }
        }
        rows[r][c] = multi[key].doubleValue
      }
    }
    return rows
  }
}
