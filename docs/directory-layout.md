# ファイル構造

ルートは Dart workspace である。配布アプリのビルド入口は `app/`。

## いまあるパッケージ

```text
.
├── app/                                   # パッケージ app。Flutter アプリケーション
│   ├── assets/icon/                       # アプリアイコンの原寸（ランタイムでは読まない）
│   ├── lib/main.dart                      # 起動入口
│   ├── lib/theme/                         # Forui テーマ
│   ├── lib/src/                           # アプリ内の非公開実装
│   ├── lib/gen/strings.dart               # 生成された文言 mixin
│   ├── res/strings.csv                    # このパッケージの文言
│   └── runner/                            # パッケージ app_runner。ARB と L10nHelper
│       ├── l10n.yaml
│       └── lib/l10n/
├── app_packages/
│   └── foundation/
│       ├── metadata/                      # foundation_metadata。Defines
│       └── resources/                     # foundation_resources。共通文言と StringsTestHelper
├── monolith.yaml
└── secrets/dart-define/                   # 生成物。git 管理外
```

`app/runner` は画面ではない。生成された多言語リソースのホストである。ネイティブの対象は `app/android` と `app/ios` だけである。

Firebase のクライアント設定は手元に置く。Git では追跡しない。置き方の制約は `docs/constraints.md` に従う。

| ファイル | パス |
| --- | --- |
| Android | `app/android/app/src/<flavor>/google-services.json` |
| iOS（保管） | `app/ios/Configurations/<CONFIGURATION>/GoogleService-Info.plist` |
| iOS（ビルド投入） | ビルド前に `app/ios/Runner/GoogleService-Info.plist` へコピー |

## 目標の配置

未作成のディレクトリは、機能を追加するときにこの形で作る。空のディレクトリは先に作らない。

```text
.
├── app/
├── app_packages/
│   ├── data/
│   │   ├── repository/<機能>/
│   │   │   ├── _impl/
│   │   │   ├── _test/
│   │   │   └── _testing/
│   │   ├── database/
│   │   └── injection/
│   ├── domain/<概念>/
│   ├── foundation/
│   ├── infra/<関心>/
│   │   ├── _mobile/
│   │   └── _testing/
│   ├── screen/
│   │   ├── navigation/
│   │   │   └── _go_router/
│   │   ├── feature/<画面>/
│   │   └── injection/
│   ├── testing/
│   ├── usecase/<機能>/
│   │   ├── _impl/
│   │   └── _test/
│   └── view/
│       └── designkit/
├── app_packages_fork/                     # フォークしたライブラリ
├── docs/
├── templates/
└── tool/
```

## パッケージの中

- ルート `pubspec.yaml` の `workspace:` にパッケージを列挙する。
- 子パッケージは `publish_to: none` と `resolution: workspace` を持つ。
- パッケージ名と `lib/<パッケージ名>.dart` を一致させる。公開 API だけを `export` する。
- 実装は `lib/src/` に置く。クラスファイルの名前とコメントは `docs/coding.md` に従う。
- ユニットテストは `test/<対象>_test.dart` に置く。Golden 画像は、そのテストファイルと同じディレクトリの `goldens/` に置く。

## 名前

| 種類 | パッケージ名の例 | パス |
| --- | --- | --- |
| 画面 | `screen_feature_<画面>` | `app_packages/screen/feature/<画面>` |
| 画面遷移 | `screen_navigation` | `app_packages/screen/navigation` |
| 遷移実装 | `screen_navigation_go_router` | `app_packages/screen/navigation/_go_router` |
| Usecase | `usecase_<機能>` | `app_packages/usecase/<機能>` |
| Usecase 実装 | `usecase_<機能>_impl` | その直下の `_impl` |
| Repository | `data_repository_<機能>` | `app_packages/data/repository/<機能>` |
| ドメイン | `domain_<概念>` | `app_packages/domain/<概念>` |
| 基盤 | `foundation_<機能>` | `app_packages/foundation/<機能>` |
| 再利用 UI | `view_<名前>` | `app_packages/view/<名前>` |

入れ子ディレクトリはアンダースコアで始める。使う接尾辞は `_impl`、`_testing`、`_test`、`_mobile`、`_go_router`。

## 生成物のパス

| 出力 | パス |
| --- | --- |
| dart-define JSON | `secrets/dart-define/<flavor>.json` |
| Defines | `app_packages/foundation/metadata/lib/gen/defines.dart` |
| パッケージ文言 mixin | `<package>/lib/gen/strings.dart` |
| ARB と L10nHelper | `app/runner/lib/l10n/` |
| テスト用 ARB ヘルパー | `app_packages/foundation/resources/lib/gen/strings_test_helper.dart` |
| Forui テーマ | `app/lib/theme/` |
| Forui 設定 | `app/forui.yaml` |
