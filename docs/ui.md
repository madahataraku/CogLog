# UI

アプリの UI は Forui で作る。テーマと設定の再生成は `app/` で行う。

```bash
dart run forui init
dart run forui theme create
```

`dart run forui theme create` は `app/lib/theme/` を上書きする。テーマの調整は生成後の `app/lib/theme/` に対して行う。

## アプリの根

`app/lib/main.dart` は次の順で組む。

1. `MaterialApp` の `supportedLocales` は `L10nHelper.supportedLocales`。
2. `localizationsDelegates` の先頭に `appLocalizationsDelegates` を置く。これは `L10nHelper.delegate` と、`material_ui` の `GlobalMaterialLocalizations.delegates` である。`MaterialApp` が後ろへ足す英語だけの delegate より先に、`ja` をサポートする delegate を置く。
3. `FLocalizations.delegate` を同じリストに含める。
4. `builder` で `FTheme`、`FToaster`、`FTooltipGroup` の順に子を包む。明暗はプラットフォームの明るさに合わせ、`lightTheme` と `darkTheme` を使う。
5. 画面の入れ物は `FScaffold` を使う。

## ボトムナビゲーション

アプリの主導線はボトムナビゲーションである。項目はホーム、メーター記録、運動履歴、目標設定の 4 つ。

- `FBottomNavigationBar` をシェルの `FScaffold.footer` に置く。
- タブは同列に切り替え、履歴には積まない。
- `FBottomNavigationBar` を `FScaffold.footer` に置くときは、双方の上ボーダーが二重にならないよう調整する。

Forui の Widget と、Cupertino または Material の Widget は同じ木に置いてよい。

## 置き場所

- 1 画面だけの Widget は、その screen パッケージに置く。
- 2 画面以上で使う Widget とデザインシステムは `view_*` に置く。
- 起動時のテーマ接続だけを `app` に残す。画面の中身を `app/lib/main.dart` に増やさない。
