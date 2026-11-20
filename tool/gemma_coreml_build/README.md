# Gemma 4 E2B Core ML バンドル生成（stateless INT4）

`google/gemma-4-E2B-it` をベースに、次の構成の on-device バンドルを作る。

| 項目 | 値 |
| --- | --- |
| ベース | `google/gemma-4-E2B-it` |
| KV | **stateless** 明示 I/O（MLState なし） |
| 量子化 | INT4 palettize（CoreML-LLM 既定） |
| Decode | T=1（chunk1–4） |
| Prefill | `prefill_b128`（`--prefill-sizes 128`） |
| 最大コンテキスト | 1024 |
| Vision | 静止画のみ（`vision.ane.*`）。video / audio は含めない |

この成果物は **CoreMLLLM の chunk 経路**向けである。現行アプリの検証用 lean monolithic（`smdesai`）取得とは別物で、アプリへ載せるときは取得マニフェストとロード経路の改修が別途必要。

## 前提

- **macOS**（Apple Silicon 推奨）。`.mlmodelc` の text-MIL コンパイルに必須
- Python **3.10–3.12**
- Xcode Command Line Tools
- Hugging Face アクセス（`gemma-4-E2B-it` が gated のときは `huggingface-cli login`）
- 空きディスク **数十 GB**（変換中の中間物＋成果物）
- 初回は数時間かかることがある

## 手順

### 1. 準備

```bash
cd /path/to/CogLog
chmod +x tool/gemma_coreml_build/*.sh

# gated モデルなら
huggingface-cli login
```

### 2. 一括ビルド

```bash
./tool/gemma_coreml_build/build_stateless_int4_bundle.sh
```

既定の出力先:

```text
.cache/gemma_coreml_build/output/gemma4-e2b-ctx1024-prefill128/bundle/
```

（`.cache/` は git 管理外想定。リポジトリにコミットしない）

### 3. よく使う環境変数

| 変数 | 既定 | 意味 |
| --- | --- | --- |
| `OUT_DIR` | `.cache/.../output/gemma4-e2b-ctx1024-prefill128` | 成果物ルート |
| `HF_DIR` | `.cache/.../hf/gemma-4-E2B-it` | ローカル HF 重み |
| `COREML_LLM_DIR` | `.cache/.../CoreML-LLM` | 変換ツールの clone |
| `COREML_LLM_REF` | `main` | CoreML-LLM の git ref |
| `CTX` | `1024` | 最大コンテキスト |
| `PREFILL_SIZE` | `128` | prefill バッチ長 |
| `SKIP_HF_DOWNLOAD` | `0` | `1` で既存 `HF_DIR` を再利用 |
| `SKIP_VISION` | `0` | `1` でテキスト＋prefill のみ |

例:

```bash
OUT_DIR=/data/gemma4-e2b-bundle \
CTX=1024 PREFILL_SIZE=128 \
./tool/gemma_coreml_build/build_stateless_int4_bundle.sh
```

### 4. 検証

ビルド末尾で `verify_bundle.sh` が走る。再実行:

```bash
./tool/gemma_coreml_build/verify_bundle.sh \
  .cache/gemma_coreml_build/output/gemma4-e2b-ctx1024-prefill128/bundle
```

### 5. 実機への載せ方（参考）

CoreML-LLM の USB sideload と同様、`Documents/Models/gemma4-e2b/` へコピーする（アプリの Bundle ID に合わせる）。

```bash
DEVICE=$(xcrun devicectl list devices | awk '/connected/{print $3}' | head -1)
xcrun devicectl device copy to \
  --device "$DEVICE" \
  --domain-type appDataContainer \
  --domain-identifier <YOUR_APP_BUNDLE_ID> \
  --source /path/to/bundle \
  --destination Documents/Models/gemma4-e2b \
  --remove-existing-content true
```

Finder のファイル共有でも可。詳細は upstream `docs/USB_MODEL_SIDELOAD.md`。

## スクリプト構成

| ファイル | 役割 |
| --- | --- |
| `build_stateless_int4_bundle.sh` | 一括オーケストレーション |
| `export_still_vision_ane.py` | 静止画 vision のみ（decoder / video なし） |
| `compile_mlpackage.py` | `.mlpackage` → `.mlmodelc`（macOS text-MIL） |
| `write_build_info.py` | `BUILD_INFO.json` 出力 |
| `verify_bundle.sh` | 必須ファイルと禁止成果物の検査 |

内部で呼び出す upstream:

- `conversion/build_gemma4_bundle.py`（INT4 chunk + prefill + sidecar）
- `conversion/models/gemma4_vision.py`（still ANE vision）

## 成果物の目安

`bundle/` 直下に概ね次があること。

- `chunk1.mlmodelc` … `chunk4.mlmodelc`
- `prefill_chunk1.mlmodelc` … `prefill_chunk4.mlmodelc`（関数 `prefill_b128`）
- `vision.ane.mlmodelc`（および元の `.mlpackage`）
- `hf_model/tokenizer.json` など
- embed / PLE / RoPE / `model_config.json`
- `BUILD_INFO.json`

**含めない:** `vision_video.*`、`audio.*`、モノリシック `model.mlpackage`（本レシピでは作らない）

## トラブルシュート

| 症状 | 確認 |
| --- | --- |
| Linux で失敗 | macOS で実行する |
| HF 403 | `huggingface-cli login` とライセンス同意 |
| ANE execution plan / -14 | 本レシピは **MLState を使わない**。それでも落ちる場合は端末メモリや別要因 |
| vision が無い | `SKIP_VISION` を切っているか、`export_still_vision_ane.py` のログを見る |
| アプリがロードしない | 現行 CogLog は lean monolithic 専用の可能性。chunk 対応の実装が必要 |

## 関連文書

- リポジトリ: `docs/gemma-coreml-stateless-build.md`
- upstream: [CoreML-LLM CONVERSION.md](https://github.com/john-rocky/CoreML-LLM/blob/main/docs/CONVERSION.md)
