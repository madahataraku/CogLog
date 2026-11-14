# Seven-segment Swift-YOLO → Core ML (`SevenSegment192.mlpackage`)

Colab での公開データ再学習（SSCMA / CC BY）は `colab_retrain.md` を先に読む。
この文書は **macOS 上での `.pth` → `.mlpackage`** のみを扱う。

重みの入手元で手順が分岐する。

| 経路 | 重み | 手順 |
| --- | --- | --- |
| A. 既存 Seeed zoo | 下記 4 の URL | 4 → 5 → 6 → 7（現行ハッシュ照合） |
| B. Colab 再学習 | Drive の `exports/*.pth` | **4 をスキップ** → 5' → 6 → 7'（新ハッシュを NOTICE に記録） |

## 実行環境（必須）

変換と `.mlpackage` の保存は **macOS 必須**である。

- `coremltools` の `mlprogram` 保存はネイティブ `BlobWriter`（`libmilstoragepython`）に依存する
- Linux ではグラフ変換まで進んでも `RuntimeError: BlobWriter not loaded` で保存できない（Cloud Agent / Linux CI では完了不可）
- Core ML ランタイムでの形状確認も macOS / iOS 上で行う
- **実機 Mac の Python** で入れる。Rosetta / 純ソース build / Linux 用 wheel だと `libcoremlpython` / `libmilstoragepython` が欠ける

## 依存（ピン留め例）

- macOS + **Python 3.10 推奨**（`scikit-learn==1.1.2` に 3.11 向け wheel が無い。`coremltools==7.2` は 3.12+ 不可）
- `torch==2.2.0`（coremltools 7.2 の検証済み上限。2.2.2 は警告が出る）
- `coremltools==7.2`（`numpy<2` と併用。**macOS 用 binary wheel** であること）
- `scikit-learn==1.1.2`（coremltools の上限。3.10 向け wheel を使う）
- `mmengine` / `pycocotools`（ModelAssistant の import に必要）
- [Seeed-Studio/ModelAssistant](https://github.com/Seeed-Studio/ModelAssistant)（Swift-YOLO 定義。Colab と同系なら `2.0.0`、main でも可）

NOTE: ModelAssistant main の `YOLOv5CSPDarknet.build_stage_layer` が `make_round(num_blocks)` のみだと `deepen_factor` が効かず、`state_dict mismatch (missing≈140)` になる。`convert_coreml.py` は実行時に当該 1 行を自動パッチする。手動なら:

```python
# sscma/models/backbones/csp_darknet.py の build_stage_layer
num_blocks = make_round(num_blocks, self.deepen_factor)
```

## アプリ契約（固定）

- 入力: NHWC float32 `[1, 192, 192, 3]`、画素 `/255.0`、letterbox は Dart 側
- 出力: `[1, 2268, 15]` または `[2268, 15]`。各行 `[x,y,w,h,score,c0..c9]`
- score / クラスは **0–1 系**（SSCMA `DetHead._forward` の ×100 は変換ラッパで ÷100 して TFLite 契約に揃える）
- 入出力名: `input` / `output`（macOS 変換で確認済み。Swift Runner と同値）

## 手順（推奨: 干净な venv）

1. ModelAssistant を clone する。

   ```bash
   git clone https://github.com/Seeed-Studio/ModelAssistant.git ~/ModelAssistant
   # deepen_factor を確認（無い場合は make_round(num_blocks, self.deepen_factor) に直す）
   ```

2. **Python 3.10** で venv を作り、依存を入れる（`scikit-learn==1.1.2` の binary wheel がある版）。

   ```bash
   cd /path/to/CogLog
   python3.10 -m venv .venv-coreml
   source .venv-coreml/bin/activate
   python -m pip install -U pip wheel
   # torch は必ず 2.2.0（新しい torch が入ると coremltools が警告／失敗しやすい）
   python -m pip install --force-reinstall \
     'torch==2.2.0' \
     'torchvision==0.17.0' \
     'torchaudio==2.2.0' \
     'numpy<2,>=1.26'
   python -m pip install \
     --only-binary=:all: 'coremltools==7.2' \
     'mmengine>=0.8.2' \
     'pycocotools' \
     'six' \
     'numpy<2,>=1.26' \
     'opencv-python-headless' \
     'Pillow' \
     'PyYAML' \
     'terminaltables' \
     'shapely' \
     'tqdm' \
     'albumentations' \
     'scikit-learn==1.1.2' \
     'timm'
   python -c "import torch, torchvision, numpy as np; print(torch.__version__, torchvision.__version__, np.__version__)"
   # 期待例: 2.2.0 / 0.17.0 / 1.26.x
   ```

   **入れないもの**: `pyarrow` / `lance` / `lancedb`。本物を入れると `numpy>=2` が要求され `coremltools==7.2` と衝突する。`convert_coreml.py` は import 前に空モジュールで stub する（変換に LanceDB は不要）。

   まだ `No module named '…'` が出たら、その名前だけ `pip install` する（例: `albumentations`）。`pyarrow` だけは入れない。

   `python3 --version` が 3.10 以外なら、この手順は使わない（3.11 は `scikit-learn==1.1.2` wheel 無し、3.12 以降は `coremltools==7.2` 不可）。

3. native 拡張が入ったか確認する（ここで失敗したら変換しない）。

   ```bash
   python - <<'PY'
   import platform, coremltools
   print("platform:", platform.platform())
   print("coremltools:", coremltools.__version__)
   # 公開名は BlobWriter ではなく _BlobStorageWriter
   from coremltools.libmilstoragepython import _BlobStorageWriter
   print("BlobWriter OK:", _BlobStorageWriter is not None)
   PY
   uname -m   # arm64 / x86_64
   ```

   - `7.2` と出たあと `BlobWriter: False` だけなら、古い確認スクリプトの誤判定のことが多い。上の `_BlobStorageWriter` import が通れば続行してよい
   - `No module named 'coremltools.libmilstoragepython'` → **macOS 用 wheel が入っていない**。venv を消し、`python3.10` で作り直してから `pip install --only-binary=:all: 'coremltools==7.2'` を試す
   - Linux / コンテナ上ではこの確認は必ず失敗する（仕様）

4. **経路 A のみ:** 配布重みを取得し SHA-1 `b26cffe14038a7155315c40b49f851679a547dec` を確認する。

   ```bash
   curl -fSL -o /tmp/digital_meter.pth \
     'https://files.seeedstudio.com/sscma/model_zoo/detection/electricity_meter/yolov5_tiny_1xb16_300e_coco_sha1_b26cffe14038a7155315c40b49f851679a547dec.pth'
   shasum -a 1 /tmp/digital_meter.pth
   ```

   **経路 B（Colab 再学習）:** このステップは行わない。Google Drive の
   `MyDrive/coglog_seven_segment/exports/` から `.pth` を Mac へコピーし、そのパスを
   `--weights` に渡す。

5. リポジトリルートで変換する（**Desktop などへのコピーは使わない**。`git pull` した本ファイルを実行）。

   ```bash
   cd /path/to/CogLog
   git pull
   source .venv-coreml/bin/activate   # CogLog 用 venv。Desktop/coreml の別 venv と混ぜない
   export SSCMA_ROOT=~/ModelAssistant
   # 経路 A: --weights /tmp/digital_meter.pth
   # 経路 B: --weights ~/Downloads/<colab_best_or_last>.pth
   python tool/seven_segment/convert_coreml.py \
     --weights /tmp/digital_meter.pth \
     --output app_packages/infra/meter_reading/_mobile/ios/Resources/SevenSegment192.mlpackage \
     --sscma-root "$SSCMA_ROOT"
   ```

6. スクリプトが表示する **入力名・出力名** と shape `[1, 2268, 15]` を確認する（現行同梱物は `input` / `output`）。行数が変わった場合は Dart / Swift 側の shape 契約も合わせて更新する。

7. 成果物の bytes / SHA-256 を扱う。

   - **経路 A:** `assets/seven_segment/NOTICE.md` の iOS 節と照合する（現行: 1530698 / `fae51fe4…e5ee5`）。
   - **経路 B:** スクリプトが出した bytes / SHA-256 を NOTICE の iOS 節へ**新規記録**する（旧ハッシュとの一致は求めない）。データセット引用（CC BY）も NOTICE に書く。

8. `ios/infra_meter_reading_mobile.podspec` は mlpackage が存在するときだけ `s.resources` に載せる。同梱済みなら `pod install` でバンドルされることを確認する。

## よくあるエラー

| メッセージ | 対処 |
| --- | --- |
| `No module named distutils` | Python 3.12+ を使っている。`python3.10 -m venv` で作り直す（setuptools では wheel 不足は解消しない） |
| `Torch version 2.2.2 has not been tested` | `pip install 'torch==2.2.0'` |
| `No module named 'coremltools.libcoremlpython'` / `libmilstoragepython` | macOS 用 binary wheel が無い。3.10 venv を作り直し `pip install --only-binary=:all: 'coremltools==7.2'`。Linux では不可 |
| `No module named 'pycocotools'` | `pip install pycocotools` |
| `No module named 'six'` / `terminaltables` / `albumentations` 等 | `pip install <その名前>`（ModelAssistant の間接依存。`pyarrow` 以外） |
| `Could not find a version that satisfies … scikit-learn==1.1.2`（3.11） | 推奨どおり Python 3.10 の venv を使う |
| `scikit-learn version … is not supported` | coremltools は ≤1.1.2。`pip install 'scikit-learn==1.1.2'`（変換自体は警告のみで進むこともある） |
| `state_dict mismatch (missing=140…)` | deepen_factor 未適用。最新 `convert_coreml.py` で再実行（自動パッチ）。または `csp_darknet.py` を上記 NOTE どおり手動修正 |
| `Torch version … has not been tested` / `2.15.0` 等 | `pip install --force-reinstall 'torch==2.2.0' 'torchvision==0.17.0' 'numpy<2,>=1.26'` |
| `torchvision` / `register_fake` / `roi_align` / `has no attribute 'extension'` | 壊れた torchvision。`pip uninstall -y torch torchvision torchaudio` → `pip install 'torch==2.2.0' 'torchvision==0.17.0' 'torchaudio==2.2.0'`。先に `python -c "from torchvision.ops import roi_align; print('ok')"` が通ることを確認 |
| `No module named 'torchaudio'` | `pip install 'torchaudio==2.2.0'`（torch 2.2.0 と揃える） |
| `No module named 'pyarrow'` / `pyarrow requires NumPy 2.0` | **pyarrow を入れない**。`git pull` して stub 入りの最新 `convert_coreml.py` を使う。Desktop へのコピーは古いことが多い |
| `BlobWriter not loaded` | 上と同じ（native 拡張欠落）か Linux 実行 |

## Linux での再試行結果（参考）

Cloud Agent（Linux）では次まで成功し、保存で失敗した。

- `.pth` ロード（`state_dict`、SHA-1 一致）
- ModelAssistant グラフ構築・重み strict 一致・出力 `[1,2268,15]`
- `torch.jit.trace` → `coremltools` MIL 変換
- 失敗: `RuntimeError: BlobWriter not loaded`（`mlprogram` 保存不可）
