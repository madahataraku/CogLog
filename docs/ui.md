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
- ソフトウェアキーボード表示中（`MediaQuery.viewInsets.bottom > 0`）はボトムナビを隠す。
- シェルの `FScaffold` がキーボード inset を一手に扱い、子へは `MediaQuery.removeViewInsets(removeBottom: true)` で bottom inset を渡さない（ネストした画面 `FScaffold` の二重縮小を防ぐ）。

Forui の Widget と、Cupertino または Material の Widget は同じ木に置いてよい。

## 推移

- ヘッダは `FHeader`、タイトルは「推移 / Trends」。
- 期間と比較プリセットはそれぞれ `FSelectMenuTile`。グループ Select と旧・指標組 Select は置かない。
- 比較 Select とグラフのあいだ（グラフ直上）に、条件に応じて `FButton` を置く。グラフ上へのオーバーレイはしない。許可リクエスト・履歴許可・OS 設定は、身体指標を含む比較の選択時のみ。再試行は系列の読込失敗時に比較を問わず出す。
- 許可リクエスト未実行かつ未許可（または Android の部分許可）のとき許可ボタンを出す。一度リクエストしても granted にならないときは許可ボタンを隠し、OS 設定ボタンを出す。
- グラフは `Expanded` 内の Syncfusion `SfCartesianChart`。カード化しない。異単位は左右の Y 軸。軸または凡例付近に単位を付ける。凡例（指標名と系列色）を常時出す。ツールチップで値と代表日付を示す。実線／点線はドメイン定義どおり。
- 画面が足す外側 Padding は上・左右 0、下のみ 16（ホーム基準＝明示の外周 Padding を載せすぎない）。
- 身体を含む比較で身体指標は許可済みだが Android の履歴許可が無く、表示期間が直近 30 日を超えるときは、履歴許可の再要求ボタンを出す。

## 運動履歴

- 月ヘッダの vertical 8 は維持する。旧リストの隣接余白 8 はカレンダー化に伴い廃止する。
- カレンダーは月曜始まりで、選択月の日付のみを示す（前後月の日付セルは出さない）。
- セル高さは 56 論理ピクセル。スタンプは primary 色の塗りつぶし円（直径 8）。同一日に 2 件以上あるときは件数もカレンダー上に出す。
- 読込中は月ヘッダを出し、カレンダー領域に進捗表示する。失敗時はエラーと再試行を出し、空のカレンダーと誤認させない。
- 運動履歴詳細で同一日に複数件あるときは、件数位置（何件中の何件目か）を出し PageView でめくる。1 件のときは件数表示とめくりを出さない。

## 運動履歴詳細・編集

- 詳細ヘッダ右上（suffixes）に編集（pencil）と削除（trash）。処理中は無効。
- 写真は本文最上部。高さは画面高の最大約 30%（ConstrainedBox）。
- 計測／記録は `FTileGroup`（カロリー・運動時間・距離・平均速度・運動した日時）。メタは別 `FTileGroup`（撮影・保存・作成開始）。グループ間 24。
- 日時は全文日時。編集の運動した日時は DateTime Picker（日付のあと時刻）。
- 削除・編集の破棄は `view_confirm_dialog`（`showFDialog`、`barrierDismissible: false`）。
- 編集は詳細の子ルート。遷移は `ScreenNavigation` のみ（`openExerciseHistoryEditAndWait`）。

## 置き場所

- 1 画面だけの Widget は、その screen パッケージに置く。
- 2 画面以上で使う Widget とデザインシステムは `view_*` に置く。
- モデル未ダウンロード誘導ダイアログは、ホームとメーター記録（後続）で共用するため `view_model_download_guidance` に置く。
- 削除確認と編集破棄確認は共用のため `view_confirm_dialog` に置く。
- 起動時のテーマ接続だけを `app` に残す。画面の中身を `app/lib/main.dart` に増やさない。

## モデル未ダウンロード誘導

- Forui の `showFDialog` を使う。
- `barrierDismissible` は `false`（外側タップでは閉じない）。
- アクションは縦並びで「閉じる」と「モデルを準備」。
- DialogRoute の完了（pop）は `ModelDownloadGuidanceLauncher` 内だけが行う。画面から `Navigator` を直接呼ばない。
- OS LLM（Foundation Models / Gemini Nano）向け (A) は、ホームとメーター記録で共用の `view_model_download_guidance` を使う。
- Gemma E2B 向け (B) は、 (A) が成立しないときだけアプリ起動時に同じ部品でダイアログを出す（OS LLM 非対応または画像入力非対応で、Gemma は端末対応だが未ダウンロードのとき。Gemma 自体が非対応の端末は対象外）。
- 同一プロセスの再表示禁止は (A) と (B) で別フラグとする。

## アチーブメント

- ホームの `FHeader` 右上（`suffixes`）にアチーブメントアクションを設定の左隣へ置く。アイコンは trophy。新規アチーブメントがあるとき、アイコン右上に件数なしドットを重ねる。押下でアチーブメント画面へスタック遷移する。
- アチーブメントはホームタブ内の子ルート（`/achievements`）。`FHeader.nested` と戻るアクションを使う。
- 一覧は系統セクション無しのフラットリスト。各行を枠で囲み、項目間余白は 16 論理ピクセル、水平パディングは 16。未開放は名前を隠し、達成条件と `LinearProgressIndicator` を出す。開放済みは名前・達成条件・MAX の進捗バーを出し、背景色と枠色を未開放より強調する。新規行には件数なしドットを付ける。
- 一覧の読込成功（Ready）後に最終閲覧日時を更新する。読込失敗時はエラー文言と再試行を出す（最終閲覧日時は更新しない）。

## アプリ設定とデバッグ

- ホームの `FHeader` 右上（`suffixes`）に、アチーブメントの右隣へ設定アクションを置く。押下でアプリ設定へスタック遷移する。
- アプリ設定・通知設定・OSS ライセンス・デバッグはホームタブ内の子ルート。`FHeader.nested` と戻るアクションを使う。
- アプリ設定は設定項目の一覧（上から通知設定、ライセンス、デバッグ）を `FTileGroup` とし、その下にアプリ情報専用の別 `FTileGroup`（バージョンと端末 OS。表示のみでタップでは遷移しない）を置く。ヘッダ直下の余分な余白は出さず（本文 `ListView` の top padding を 0）、二つの `FTileGroup` のあいだには 24 論理ピクセルの間隔を置く。
- 通知設定は ON/OFF を切り替え、許可拒否時は案内テキストのみを示す（再要求ダイアログなし）。
- OSS ライセンスは依存ライブラリの一覧と本文。空のときは空状態メッセージを出す。遷移は `ScreenNavigation` 経由とする。
- デバッグは、診断結果とアプリ内ログを縦スクロールで示す。
- アプリ内ログは、編集不可（`readOnly`）で選択・コピー可能な複数行テキスト領域とする。領域は固定高さで内部スクロールし、親の縦スクロールと独立して追える。並びは古い行が上・新しい行が下。追記時の自動スクロールはしない。ストアが空でも空のテキスト領域を出し、空状態専用文言は出さない。

- 画面から `Navigator` を直接呼ばない。遷移は `ScreenNavigation` 経由とする。

## メーター記録カメラ

- メーター記録タブの第一画面はアプリ内カメラである。ボトムナビはシェルの `FScaffold.footer` のまま表示する。
- プレビューはヘッダー下〜操作列上の領域を全面で埋める。カメラの表示縦横比を保ち、余白のレターボックスは作らず、はみ出しは中央基準で切り取る。
- プレビュー直下（ボトムナビの直上）に、ライブラリから選ぶ操作と丸いシャッターを置く。シャッターは通常のカメラアプリと同様の円形ボタンとし、中央に置く。
- カメラ権限拒否時はプレビューを出さず、設定案内とライブラリ選択を出す。
