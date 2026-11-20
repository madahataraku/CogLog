# iOS Gemma 4 E2B Core ML（stateless INT4 チャンク）オフライン生成

メーター読み取り用 Gemma E2B の **代替 Core ML バンドル**を、手元の Mac で生成する手順である。  
アプリ同梱はしない。現行の検証用ダウンロード既定（Hugging Face `smdesai` lean monolithic）とは別系統である。

## 目標構成

| 項目 | 値 |
| --- | --- |
| ベース重み | `google/gemma-4-E2B-it` |
| ランタイム想定 | CoreMLLLM の **chunk** 経路（`chunk1` あり） |
| KV | **stateless** 明示 I/O（MLState は使わない。ANE の execution plan 失敗を避ける） |
| 量子化 | INT4 palettize |
| Decode | シーケンス長 1 |
| Prefill | シーケンス長 128（`prefill_b128`） |
| 最大コンテキスト | 1024 |
| Vision | 静止画のみ。`vision_video` / `audio` は生成しない |

チャンク境界は CoreML-LLM 既定の SWA 分割（E2B: L0–7 / L8–14 / L15–24 / L25–34）に従う。

## 実行入口

手順とスクリプトは `tool/gemma_coreml_build/` に置く。

```bash
./tool/gemma_coreml_build/build_stateless_int4_bundle.sh
```

詳細（環境変数、検証、sideload）は同ディレクトリの `README.md` を読む。

## アプリへの取り込み

このバンドルを製品のダウンロード既定にするときは、次を別変更で行う。

1. `docs/product.md` / `docs/constraints.md` の iOS 取得方針を更新する  
2. `infra_gemma_meter_mobile` の取得マニフェストとロードを chunk 構成向けに切り替える  
3. 実機（特にメモリの少ない端末）で prepare → 画像付き生成を検証する  

## 採用しないもの

- `google/gemma-4-E2B-it-qat-mobile-transformers`（wNa8o8。CoreML-LLM 変換の入力向きではない）  
- MLState 付きチャンク（ANE では実行計画失敗が既知）  
- LiteRT の `.litertlm` からの直接変換（不可。HF 重みから変換する）  
