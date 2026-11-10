# UI

アプリの UI は Forui で作る。テーマと設定の再生成は `app/` で行う。

```bash
dart run forui init
dart run forui theme create
```

`dart run forui theme create` は `app/lib/theme/` を上書きする。テーマの調整は生成後の `app/lib/theme/` に対して行う。

色の方針は次のとおり。

- ベースカラーは Forui の Olive（`app/lib/theme/colors.dart`）。
- アプリの primary は `#F6AD49`。`primaryForeground` はコントラストのため Olive の暗い前景（`#1D1D16`）。
- ボトムナビの選択タブは `primary` ではなく `foreground` を使う（白／暗背景で十分なコントラストを確保するため）。
- `#F6AD49` により合う暖色ニュートラルとして Stone も候補。ベースを差し替えるときは `dart run forui theme create --preset babbbc` を使う。

`dart run forui theme create --preset eabbbc`（Stone なら `babbbc`）のあと、次を手で戻す。

1. `lightColors` / `darkColors` の `primary` を `#F6AD49`、`primaryForeground` を `#1D1D16` にする。
2. `darkColors` の `destructiveForeground` と `errorForeground` をどちらも `#171717` に戻す。
3. 再生成後の `theme.dart` には選択色の設定が無いので、現在の `_bottomNavigationBarStyle` を復元し、`lightTheme` と `darkTheme` の両方へ渡す。アイコンと文字の選択色はどちらも `foreground` にする。

## アプリの根

`app/lib/main.dart` は次の順で組む。

1. `MaterialApp` の `supportedLocales` は `L10nHelper.supportedLocales`。
2. `localizationsDelegates` の先頭に `appLocalizationsDelegates` を置く。これは `L10nHelper.delegate` と、`material_ui` の `GlobalMaterialLocalizations.delegates` である。`MaterialApp` が後ろへ足す英語だけの delegate より先に、`ja` をサポートする delegate を置く。
3. `FLocalizations.delegate` を同じリストに含める。
4. `builder` で `FTheme`、`FToaster`、`FTooltipGroup` の順に子を包む。明暗はプラットフォームの明るさに合わせ、`lightTheme` と `darkTheme` を使う。
5. 画面の入れ物は `FScaffold` を使う。

## ボトムナビゲーション

アプリの主導線はボトムナビゲーションである。項目はホーム、メーター記録、推移、運動履歴、目標設定の 5 つ。

- `FBottomNavigationBar` をシェルの `FScaffold.footer` に置く。
- タブは同列に切り替え、履歴には積まない。
- `FBottomNavigationBar` を `FScaffold.footer` に置くときは、双方の上ボーダーが二重にならないよう調整する。

Forui の Widget と、Cupertino または Material の Widget は同じ木に置いてよい。

## 推移

- ヘッダは `FHeader`、タイトルは「推移 / Trends」。
- 期間とグループはそれぞれ `FSelect`。その直下にグループ内の指標 `FSelect` を置く。
- 指標 Select とグラフのあいだ（グラフ直上）に、条件に応じて `FButton` を置く。グラフ上へのオーバーレイはしない。許可リクエスト・履歴許可・OS 設定は身体グループ選択時のみ。再試行は系列の読込失敗時にグループを問わず出す。
- 許可リクエスト未実行かつ未許可（または Android の部分許可）のとき許可ボタンを出す。一度リクエストしても granted にならないときは許可ボタンを隠し、OS 設定ボタンを出す。
- グラフは `Expanded` 内の `CustomPaint`。点と実線／点線。カード化しない。
- 複数指標を同時表示するときは、指標名と系列色を対応付けた凡例をグラフ領域内（描画の上）に出す。
- 身体グループで身体指標は許可済みだが Android の履歴許可が無く、表示期間が直近 30 日を超えるときは、履歴許可の再要求ボタンを出す。

## 置き場所

- 1 画面だけの Widget は、その screen パッケージに置く。
- 2 画面以上で使う Widget とデザインシステムは `view_*` に置く。
- モデル未ダウンロード誘導ダイアログは、ホームとメーター記録（後続）で共用するため `view_model_download_guidance` に置く。
- 起動時のテーマ接続だけを `app` に残す。画面の中身を `app/lib/main.dart` に増やさない。

## モデル未ダウンロード誘導

- Forui の `showFDialog` を使う。
- `barrierDismissible` は `false`（外側タップでは閉じない）。
- アクションは縦並びで「閉じる」と「モデルを準備」。
- DialogRoute の完了（pop）は `ModelDownloadGuidanceLauncher` 内だけが行う。画面から `Navigator` を直接呼ばない。

## アプリ設定とデバッグ

- ホームの `FHeader` 右上（`suffixes`）に設定アクションを置く。押下でアプリ設定へスタック遷移する。
- アプリ設定・デバッグはホームタブ内の子ルート。`FHeader.nested` と戻るアクションを使う。
- アプリ設定は設定項目の一覧（当面はデバッグのみ）。デバッグは診断結果とアプリ内ログを縦スクロールで示す。
- 画面から `Navigator` を直接呼ばない。遷移は `ScreenNavigation` 経由とする。

## メーター記録カメラ

- メーター記録タブの第一画面はアプリ内カメラである。ボトムナビはシェルの `FScaffold.footer` のまま表示する。
- プレビューはヘッダー下〜操作列上の領域を全面で埋める。カメラの表示縦横比を保ち、余白のレターボックスは作らず、はみ出しは中央基準で切り取る。
- プレビュー直下（ボトムナビの直上）に、ライブラリから選ぶ操作と丸いシャッターを置く。シャッターは通常のカメラアプリと同様の円形ボタンとし、中央に置く。
- カメラ権限拒否時はプレビューを出さず、設定案内とライブラリ選択を出す。
