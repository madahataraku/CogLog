# Seven-segment Swift-YOLO → Core ML (`DigitalMeterElectricity192.mlpackage`)

## 実行環境（必須）

変換と `.mlpackage` の保存は **macOS 必須**である。

- `coremltools` の `mlprogram` 保存はネイティブ `BlobWriter`（`libmilstoragepython`）に依存する
- Linux ではグラフ変換まで進んでも `RuntimeError: BlobWriter not loaded` で保存できない（Cloud Agent / Linux CI では完了不可）
- Core ML ランタイムでの形状確認も macOS / iOS 上で行う

## 依存（ピン留め例）

- macOS + **Python 3.10 または 3.11 を推奨**（3.12+ は標準から `distutils` が消え、`No module named distutils` になりやすい）
- `torch` 2.2.x（`.pth` ロード用）
- `coremltools` 7.2（`numpy<2` と併用）
- `setuptools`（3.12 を使う場合の `distutils` 互換。先に入れる）
- [Seeed-Studio/ModelAssistant](https://github.com/Seeed-Studio/ModelAssistant)（Swift-YOLO 定義。Colab と同系なら `2.0.0`、main でも可）
- `mmengine`（ModelAssistant / チェックポイント周辺）

NOTE: ModelAssistant main の `YOLOv5CSPDarknet.build_stage_layer` が `make_round(num_blocks)` のみだと `deepen_factor` が効かず、重みとブロック数が不一致になる。変換前に `make_round(num_blocks, self.deepen_factor)` になっていることを確認する。

## アプリ契約（固定）

- 入力: NHWC float32 `[1, 192, 192, 3]`、画素 `/255.0`、letterbox は Dart 側
- 出力: `[1, 2268, 15]` または `[2268, 15]`。各行 `[x,y,w,h,score,c0..c9]`
- score / クラスは **0–1 系**（SSCMA `DetHead._forward` の ×100 は変換ラッパで ÷100 して TFLite 契約に揃える）
- 入出力名は変換成功時の値が正。現状プレースホルダは `input` / `output`（変換後に本ファイルと `SevenSegmentCoreMlRunner.swift` を同値に更新）

## 手順

1. 重みを取得し SHA-1 `b26cffe14038a7155315c40b49f851679a547dec` を確認する。

   ```bash
   curl -fSL -o /tmp/digital_meter.pth \
     'https://files.seeedstudio.com/sscma/model_zoo/detection/electricity_meter/yolov5_tiny_1xb16_300e_coco_sha1_b26cffe14038a7155315c40b49f851679a547dec.pth'
   shasum -a 1 /tmp/digital_meter.pth
   ```

2. ModelAssistant を用意し、Swift-YOLO tiny を `num_classes=10` / `192²` / `deepen_factor=0.33` / `widen_factor=0.15` で構築できる状態にする。

3. リポジトリルートで変換スクリプトを実行する（**macOS**）。

   ```bash
   python3 --version   # 3.10 / 3.11 推奨。3.12+ なら次行の setuptools が必須
   python3 -m pip install -U 'setuptools>=69' \
     'coremltools==7.2' 'torch==2.2.2' 'numpy<2' 'mmengine>=0.8.2'
   # ModelAssistant を import 可能にしてから:
   export SSCMA_ROOT=/path/to/ModelAssistant
   python3 tool/seven_segment/convert_coreml.py \
     --weights /tmp/digital_meter.pth \
     --output app_packages/infra/meter_reading/_mobile/ios/Resources/DigitalMeterElectricity192.mlpackage \
     --sscma-root "$SSCMA_ROOT"
   ```

   `No module named distutils` が出たら、いまのインタプリタが 3.12+ の可能性が高い。上記 `setuptools` を入れ直すか、`pyenv` / Homebrew の Python 3.11 で venv を作り直す。

4. スクリプトが表示する **入力名・出力名** と shape `[1, 2268, 15]` を確認し、本ファイルと `SevenSegmentCoreMlRunner.swift` の定数をそれに合わせる。

5. 成果物の bytes / SHA-256 を `assets/seven_segment/NOTICE.md` の iOS 節へ転記する。

6. `ios/infra_meter_reading_mobile.podspec` は mlpackage が存在するときだけ `s.resources` に載せる（未配置時は CocoaPods を壊さない）。配置後は `pod install` でバンドルされることを確認する。

## Linux での再試行結果（参考）

Cloud Agent（Linux）では次まで成功し、保存で失敗した。

- `.pth` ロード（`state_dict`、SHA-1 一致）
- ModelAssistant グラフ構築・重み strict 一致・出力 `[1,2268,15]`
- `torch.jit.trace` → `coremltools` MIL 変換
- 失敗: `RuntimeError: BlobWriter not loaded`（`mlprogram` 保存不可）
