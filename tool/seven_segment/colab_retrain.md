# Seven-segment Swift-YOLO retraining on Colab (public datasets)

AGPL の Ultralytics を使わず、**SSCMA / ModelAssistant（Apache License 2.0）** で桁検出を再学習し、CogLog 既存契約（入力 192・クラス 0–9）に合わせる手順。

自前撮影データは使わない前提。無料 Colab（T4 が取れれば十分）向け。

## 成果物の置き場

| 成果物 | 行き先 |
| --- | --- |
| TFLite FLOAT32 | `app_packages/infra/meter_reading/_mobile/assets/seven_segment/*.tflite` |
| `.pth` | Mac で `convert_coreml.py` の入力 |
| Core ML | macOS 必須（`convert_coreml.md`） |
| ライセンス | 同ディレクトリ `NOTICE.md` を更新 |

## 公開データセット

### 主推奨: LibreYOLO / digits-t2eg6（CC BY 4.0）

| 項目 | 内容 |
| --- | --- |
| URL | https://huggingface.co/datasets/LibreYOLO/digits-t2eg6 |
| 件数 | 約 4,100 枚（train/valid/test） |
| クラス | `0`–`9`（CogLog 契約と一致） |
| 形式 | YOLO txt → 本ツールで COCO 化 |
| 領域 | デジタル LCD / ノギス等の七セグ寄り実写 |

API キー不要。Hugging Face から取得できる。

### 任意: Roboflow treadmill-ocr（フィットネス寄り）

| 項目 | 内容 |
| --- | --- |
| URL | https://universe.roboflow.com/gabolauro/treadmill-ocr-gqnwo |
| 注意 | **Cite の License を必ず確認**。未記載は all rights reserved。permissive（例: CC BY）のときだけ使う |
| 前処理 | `remap_treadmill_ocr_labels.py` でフォント差分を 0–9 に畳み、記号クラスは捨てる |

### 使わないもの

| 候補 | 理由 |
| --- | --- |
| SSCMA `meter.zip` | アナログ指針向けで、桁 bbox データではない |
| Ultralytics 学習 / YOLOv8+ 重み | AGPL リスク（本パイプラインの対象外） |
| CC BY-NC データ | アプリ同梱・再配布と相性が悪い |

## アプリ契約（固定）

現行七セグと同じく揃える。

- 入力: NHWC float32 `[1, 192, 192, 3]`、画素 `/255.0`、letterbox は Dart
- クラス数: **10**（digit 0–9）
- 出力行: `[x,y,w,h,score,c0..c9]`（幅 15）。アンカー構成が変わると行数（現行 2268）も変わり得る → 差し替え時に Dart / Core ML 側を合わせて確認する

## Colab 手順（概要）

1. ランタイムを GPU にする（無料枠の T4 で可）。
2. リポジトリの `tool/seven_segment/colab_sscma_retrain.ipynb` を Colab にアップロードして上から実行する。
3. ノートブックが行うこと:
   - ModelAssistant を clone
   - `digits-t2eg6` を取得し COCO 化（`prepare_digits_t2eg6.py`）
   - Swift-YOLO tiny・`imgsz=192`・`num_classes=10` で学習
   - `export_tflite_float32.py` で **FLOAT32** TFLite を export（SSCMA `tools/export.py` は INT8 のみなので使わない）
   - 学習中の checkpoint も Drive 上の `work_dirs` に置く
   - Drive へ `.pth` / `.tflite` を保存
4. Mac で `convert_coreml.md` の **Colab 再学習重み** 節に従い `.mlpackage` を作る（配布 zoo 重みの取得はスキップ）。
5. アプリ資産と `NOTICE.md` を差し替え、実機で確認する。

ローカル（GPU マシン）でも同じスクリプトで再現できる。

```bash
cd tool/seven_segment
python3 -m pip install pillow huggingface_hub
python3 prepare_digits_t2eg6.py --work-dir ../../datasets/digits_t2eg6
# 続いて ModelAssistant の tools/train.py / tools/export.py（ノートブック参照）
```

変換単体テスト:

```bash
cd tool/seven_segment
python3 -m pip install pillow
python3 test_yolo_txt_to_coco.py
```

## 無料 Colab の注意

- セッション切断に備え、checkpoint と最終重みを Drive に都度保存する。
- GPU が付かないときは学習を始めない（CPU は非現実的）。
- まず 30–50 epoch の smoke、問題なければ 100–150 epoch 程度を目安にする（データ規模と枠に合わせて調整）。

## NOTICE 記載例（学習後）

```text
Training dataset: LibreYOLO/digits-t2eg6 (CC BY 4.0)
https://huggingface.co/datasets/LibreYOLO/digits-t2eg6
Trainer: Seeed-Studio/ModelAssistant (Apache-2.0), Swift-YOLO tiny 192
```

