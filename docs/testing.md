# テスト方針

ロジックにはユニットテストを必ず付ける。画面と UI には Golden Test を必ず付ける。見た目の検証をユニットテストで代用しない。ロジックの分岐を Golden Test で代用しない。

## ユニットテスト

次を追加・変更したときは、同じ変更でユニットテストを追加・更新する。

- Usecase
- ドメインの計算、判定、変換
- Repository と data の読み書きロジック
- ViewModel の状態遷移
- foundation や infra のロジック

テストは、そのパッケージの `test/` に `<対象>_test.dart` として置く。Flutter パッケージは `flutter test`、Dart だけのパッケージは `dart test` で実行する。

外部の OS や通信は、本番実装の代わりに `_test` または `_testing` の Fake を注入する。本番パッケージからそれらのパッケージへ依存しない。

文言を読むテストは、`docs/localization.md` の `StringsTestHelper` で注入する。

`foundation_metadata` のテストは、`dart run monolith_runner:define` で `secrets/dart-define/test.json` を作ってから実行する。

## Golden Test

利用者が見る画面と、再利用する UI を追加・変更したときは、同じ変更で Golden Test を追加・更新する。

- screen の View
- view パッケージの Widget
- `app` に残している起動時の画面

Golden Test は、その Widget を持つパッケージの `test/` に置く。期待画像は、テストファイルと同じディレクトリの `goldens/` に置く。`matchesGoldenFile` のパスはテストファイルからの相対パスである。

```dart
await expectLater(
  find.byType(HomeScreen),
  matchesGoldenFile('goldens/home_screen.png'),
);
```

撮影条件はテスト内で固定する。

- ロケールは `ja`
- `debugDefaultTargetPlatformOverride` で Android または iOS に固定する。実行マシンの OS では撮らない
- Android と iOS でピクセルが違うときは、画像を分ける
- 明るさは `platformBrightnessTestValue` で light または dark に固定する
- 表面サイズをテストが指定する。指定しない場合は Flutter テストの既定サイズのままにし、テストの途中でサイズを変えない
- テーマは `app/lib/theme` の light を使う。dark の見た目を変えたときは dark の Golden も追加する

固定した値は、そのテストの終了時に戻す。戻さないと後続テストへ残り、実行順で結果が変わる。`addTearDown` か `try/finally` を使う。

- `platformBrightnessTestValue` は `clearPlatformBrightnessTestValue`
- ロケールは `clearLocalesTestValue`
- 表面サイズは `resetPhysicalSize`
- device pixel ratio は `resetDevicePixelRatio`
- `debugDefaultTargetPlatformOverride` は `null`。これはテスト本体が終わる前に戻す

画面が `L10nHelper` を読み込む Golden Test は、`StringsTestHelper` を注入しない。読み込まないテストは、撮影前に `StringsTestHelper.ja` を注入し、終了時に `LocalizeStringDelegate.resetDelegateForTest` を呼ぶ。

意図した見た目の変更だけ、次で期待画像を更新し、差分をコミットする。

```bash
flutter test --update-goldens
```

失敗時の差分を期待画像としてコミットしない。

期待画像は Linux CI（PR Checks / App Distribution の android レッグ）の描画を正とする。macOS 上のホスト描画差でピクセルがずれるため、App Distribution の ios レッグ（`macos-15`）では `*_golden_test.dart` を実行しない。詳細は `docs/constraints.md` の App Distribution を参照する。
