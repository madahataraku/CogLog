# 開発上の制約

レイヤーは `docs/architecture.md`、Dart の書き方は `docs/coding.md`、文言は `docs/localization.md`、UI は `docs/ui.md` に従う。ここにはそれらをまたぐ制約を書く。

## Workspace

- 依存の実効バージョンはルート `pubspec.yaml` の `dependency_overrides` に書く。
- 子パッケージの外部依存は `any` にする。
- `flutter pub get` と Monolith のコマンドはリポジトリルートで実行する。
- `flutter run` と `dart run forui` は `app/` で実行する。
- 外部パッケージをパッチするときは `app_packages_fork/` に置き、ルートの `dependency_overrides` で path 指定する。端末上 LLM は `infra_on_device_llm_mobile` の自前 Flutter plugin（OS モデルのみ）を使う。AICore / GenAI の診断（例外型名を含む）もその実装が担う。

## Syncfusion Charts

- 推移グラフは `syncfusion_flutter_charts` を用いる。Community License（または Commercial）を利用する。
- Flutter 向けパッケージ（v18.3 以降）はアプリ内のライセンスキー登録を必要としない。キーの dart-define 注入や `SyncfusionLicense.registerLicense` は行わない。
- 実効バージョンはルート `pubspec.yaml` の `dependency_overrides` で固定する。
- 依存は OSS ライセンス一覧の再生成対象に含める。

## フレーバー

`monolith.yaml` の `define.flavors` は `development`、`production`、`test`。値はすべて文字列にする。`test` はテストが読む dart-define 用で、中身は development に揃える。ネイティブの `--flavor` には `test` を置かない（AGP が `test` で始まる productFlavor 名を拒否するためでもある）。

```bash
dart run monolith_runner:define
```

出力先 `secrets/dart-define/` は git に入れない。`foundation_metadata` のテストは `secrets/dart-define/test.json` がある状態で実行する。

ネイティブのアプリ ID（Android `applicationId` / iOS Bundle Identifier）は `--flavor`（`development` / `production`）だけで切り替える。buildType（debug / release）では変えない。

| flavor | applicationId / Bundle Identifier |
| --- | --- |
| development | `io.github.madahataraku.coglog.debug` |
| production | `io.github.madahataraku.coglog` |

開発ビルド:

```bash
cd app
flutter run --flavor development \
  --dart-define-from-file=../secrets/dart-define/development.json
```

## 秘密情報

- `secrets/` はコミットしない。
- 秘密の注入元は `monolith.yaml` の `includes` にある `secrets/monolith.yaml`。
- 1Password を使うときは `op inject --force --in-file monolith.yaml --out-file secrets/monolith.yaml` のあと、`dart run monolith_runner:install` を実行する。

## 生成ファイル

Monolith が書く次のファイルは手で編集しない。

- `app_packages/foundation/metadata/lib/gen/defines.dart`
- 各パッケージの `lib/gen/strings.dart`
- `app_packages/foundation/resources/lib/gen/strings_test_helper.dart`
- `app/runner/lib/l10n/`

入力側（`monolith.yaml` と `res/strings.csv`）を変えて、対応するコマンドを再実行する。

## Android

`app/android/app/build.gradle.kts` の SDK は次に固定する。

| 項目 | 値 |
| --- | --- |
| `minSdk` | `34` |
| `compileSdk` | `flutter.compileSdkVersion`（Flutter 3.47 系では 36） |
| `targetSdk` | `flutter.targetSdkVersion`（Flutter 3.47 系では 36） |

`minSdk` は 34 未満にしない。プラグイン側が `compileSdk` 33 などに固定されていると `checkReleaseAarMetadata` が失敗するため、依存は `compileSdk` 34 以上の版を `dependency_overrides` で選ぶ。

空間 OCR（Android）は `google_mlkit_text_recognition` を使う。日本語モデルはプラグイン側が `compileOnly` のため、`app/android/app/build.gradle.kts` に `com.google.mlkit:text-recognition-japanese` を `implementation` する。release の R8 で Text Recognition の反射登録が欠けないよう、`app/android/app/proguard-rules.pro` に `com.google.mlkit.vision.**` などの keep を置く。

## iOS

`IPHONEOS_DEPLOYMENT_TARGET` と `app/ios/Podfile` の `platform :ios` は次に固定する。プラグイン（`infra_meter_reading_mobile` / `infra_on_device_llm_mobile`）が 16.4 を要求するため、これ未満にしない。

| 項目 | 値 |
| --- | --- |
| `IPHONEOS_DEPLOYMENT_TARGET` | `16.4` |
| Podfile `platform :ios` | `16.4` |

Bundle Identifier は上記フレーバー対応表に従う。`dart run monolith_runner:xcodegen` は、各構成の Bundle Identifier、Provisioning Profile、Team ID が揃ってから実行する。Provisioning Profile と Team ID は未指定のため、いまは xcodegen を実行しない。指示に無い署名の値は作らない。

## Firebase

クライアント設定は手元に置き、Git では追跡しない。フレーバーごとにファイルを分ける（1 ファイルに両アプリ ID を入れない）。

- Android は `app/android/app/src/<flavor>/google-services.json`。プラグイン `com.google.gms.google-services` を `app/android/settings.gradle.kts` で宣言し、`app/android/app/build.gradle.kts` で適用する。各ファイルの `package_name` は、そのフレーバーの `applicationId` と一致させる。
- iOS の保管先は `app/ios/Configurations/<CONFIGURATION>/GoogleService-Info.plist`（例: `Debug-development`）。同一フレーバーの Debug / Profile / Release は同じ内容を置く。ビルド前に選んだ構成の plist を `app/ios/Runner/GoogleService-Info.plist` へコピーし、Runner ターゲットのリソースとして含める。

```bash
# flavor=development・Debug の例
cp app/ios/Configurations/Debug-development/GoogleService-Info.plist \
  app/ios/Runner/GoogleService-Info.plist
```

`google-services.json` と `GoogleService-Info.plist` は `.gitignore` に入る。リポジトリへ追加しない。

Firebase コンソールでは、Android / iOS それぞれに development（`.debug`）用と production 用のアプリを持つ。1Password の `CogLog_develop` に置く development 向け添付は、package name / Bundle ID が `io.github.madahataraku.coglog.debug` であることを期待する。production 向けはアイテム `CogLog_production` を使う。

XcodeGen へ移すときは、署名条件が揃ってから行う。そのときも plist の保管は `app/ios/Configurations/<CONFIGURATION>/GoogleService-Info.plist` とし、ビルド前にアプリバンドルへコピーする。

## PR チェック

`.github/workflows/pr-checks.yml` は、`main` 向けの pull_request で次を実行する。秘密情報や Environment は使わない。

| ジョブ名（必須ステータスチェック名） | 内容 |
| --- | --- |
| Format | リポジトリルートで `flutter pub get` のあと `dart format --output=none --set-exit-if-changed .` |
| Analyze | リポジトリルートで `flutter pub get` のあと `flutter analyze` |
| Test | マトリクスシャード（`Test packages`）の結果を集約するジョブ。シャードがすべて成功したときだけ成功する |

`Test packages` は必須ステータスチェックには入れない。`strategy.matrix.shard`（現状は `0` / `1` / `2` の 3 本）で並列実行し、`fail-fast: false` とする。各シャードはリポジトリルートで `flutter pub get` と `dart run monolith_runner:define` のあと、ソートした `test/` 付きパッケージ一覧のうち `index % shard数 == shard` に当たるものだけを実行する。`sdk: flutter` を持つパッケージは `flutter test`、それ以外は `dart test`。ユニットテストと Golden Test の両方を含む。

Flutter の版は App Distribution と同じく `3.47.9`（stable）に固定する。外部 Action はコミット SHA にピン留めする。

これらのチェックをマージ条件にするため、Ruleset `mainブランチ` の required status checks に、上表のジョブ名 `Format`・`Analyze`・`Test` を入れる（シャード名は入れない）。設定場所は **Settings → Rules → mainブランチ** である。ワークフローを一度 `main` へマージして実行実績が出てから、チェック名を選べる。

## Daily チェック

`.github/workflows/daily-checks.yml` は、`main` に対して日次で Analyze と全パッケージテストを実行する。秘密情報や Environment は使わない。トリガーは `schedule`（毎日 17:00 UTC = 翌 02:00 JST）と、手動の `workflow_dispatch` である。checkout の `ref` は常に `main` とする。

| ジョブ名 | 内容 |
| --- | --- |
| Analyze | PR Checks の Analyze と同じ（`flutter pub get` のあと `flutter analyze`） |
| Test | PR Checks と同じく、`Test packages` のマトリクスシャード（`0` / `1` / `2`）を集約する |

`Test packages` の分割方法・Flutter 版・Action の SHA ピン留めは PR Checks と同じである。Golden Test も含め、runner は `ubuntu-latest` のみとする。App Distribution では Analyze / テストを回さないため、main 上の回帰は Daily チェックで拾う。

## App Distribution

`.github/workflows/app-distribution.yml` は、`main` への push と、`main` を選んだ手動の `workflow_dispatch` で、Android の release APK と iOS の Ad Hoc IPA を Firebase App Distribution へ出す。ジョブは `github.ref == refs/heads/main` のときだけ動き、Environment `app-distribution` を使う。

単一ジョブ `distribute` を `strategy.matrix.platform`（`android` / `ios`）で回す。`fail-fast: false` とし、Android と iOS は並列で、片方の失敗がもう片方をキャンセルしない。runner は Android が `ubuntu-latest`、iOS が `macos-26` である。`infra_on_device_llm_mobile` が `FoundationModels` をリンクするため、Xcode 26 SDK を含む `macos-26` を使う（`macos-15` では Framework not found になる）。

push のフレーバーは `development`。手動起動では `development` または `production` を選ぶ。`test` は配布しない。dart-define は、リポジトリルートの `dart run monolith_runner:define` が書く `secrets/dart-define/<flavor>.json` を使う。`secrets/monolith.yaml` が無い include は読み飛ばす。

Android のクライアント設定は、Actions 上でフレーバー別パスへ配置する。`development` は `CogLog_develop`、`production` は `CogLog_production` を読む。

```bash
# development の例
mkdir -p app/android/app/src/development
op read --force --out-file app/android/app/src/development/google-services.json \
  "op://AppDevelopment/CogLog_develop/google-services.json"
```

```bash
# production の例
mkdir -p app/android/app/src/production
op read --force --out-file app/android/app/src/production/google-services.json \
  "op://AppDevelopment/CogLog_production/google-services.json"
```

配置後、ファイル内の `package_name` がそのフレーバーの `applicationId` と一致することを検証する。APK は `flutter build apk --release --flavor <flavor>` で出し、成果物は `app-<flavor>-release.apk` である。Firebase App Distribution のアプリ ID も、同じフレーバーの `package_name` から解決する。

iOS のクライアント設定と署名も、同じフレーバーの 1Password アイテムから読む。development は `CogLog_develop`、production は `CogLog_production`。Team ID・証明書・Provisioning Profile の実値はリポジトリに書かず、Actions 上だけで使う。`ExportOptions.plist` も CI で生成する（method は `ad-hoc`、signingStyle は `manual`）。

```bash
# development の例（production は CogLog_production）
op read --force --out-file secrets/ios/GoogleService-Info.plist \
  "op://AppDevelopment/CogLog_develop/GoogleService-Info.plist"
op read --force --out-file secrets/ios/ios-distribution.p12 \
  "op://AppDevelopment/CogLog_develop/ios-distribution.p12"
op read --force --out-file secrets/ios/ios-adhoc.mobileprovision \
  "op://AppDevelopment/CogLog_develop/ios-adhoc.mobileprovision"
```

同じアイテムのフィールド `ios-distribution-password` と `ios-team-id` も読む。プロファイル名は `.mobileprovision` から取り、リポジトリへは書かない。`BUNDLE_ID` / プロファイルの App ID は、そのフレーバーの Bundle Identifier と一致することを検証する。加えて、`ios-distribution.p12` のリーフ証明書が `ios-adhoc.mobileprovision` の `DeveloperCertificates` に含まれることも検証する。一致しないと Xcode が「Provisioning profile doesn't include signing certificate」で止む。直し方は Apple Developer で Ad Hoc プロファイルを、その Distribution 証明書を選んで作り直し 1Password の `ios-adhoc.mobileprovision` を差し替えるか、プロファイル側に含まれる証明書の `.p12` に置き換える。plist は `app/ios/Configurations/<CONFIGURATION>-<flavor>/` と `app/ios/Runner/GoogleService-Info.plist` へコピーする。IPA は `flutter build ipa --release --flavor <flavor> --export-options-plist ...` で出し、Firebase App Distribution のアプリ ID は plist の `GOOGLE_APP_ID` から解決する。

配布用 secret は、GitHub の Environment `app-distribution` に置く。リポジトリ secret には置かない。Environment の Deployment branches は Selected branches で `main` だけを許可する。設定場所は **Settings → Environments → app-distribution** である。

- `OP_SERVICE_ACCOUNT_TOKEN`。vault `AppDevelopment` を読める 1Password サービスアカウント。
- `GCP_WORKLOAD_IDENTITY_PROVIDER`。このリポジトリ向けの Workload Identity Federation プロバイダ資源名。
- `GCP_SERVICE_ACCOUNT`。サービスアカウントのメールアドレス。Google Cloud のプロジェクト IAM で、このメンバーに `roles/firebaseappdistro.admin` を付ける。

同じサービスアカウントには、リポジトリ `madahataraku/CogLog` の `main` からだけなれるようにする。Workload Identity プロバイダの属性マッピングは次にする。`attribute.repository` が無いと、IAM の principal はトークンと一致しない。

```text
google.subject=assertion.sub
attribute.repository=assertion.repository
```

属性条件は次にする。この条件が、`main` 以外の ref を拒否する。

```text
assertion.repository=='madahataraku/CogLog' && assertion.ref=='refs/heads/main'
```

IAM の principal はリポジトリ単位である。管理場所は Google Cloud コンソールの **IAM と管理 → サービス アカウント → 対象アカウント → 権限** である。そこへ次の principal に `roles/iam.workloadIdentityUser` を付ける。

```text
principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github/attribute.repository/madahataraku/CogLog
```

テスターグループはリポジトリ変数 `FIREBASE_APP_DISTRIBUTION_GROUPS` にカンマ区切りで置く。手動起動の `groups` 入力があるときはそれを使う。

Analyze とパッケージテストは App Distribution では実行しない。PR では PR Checks、main の日次では Daily チェックが担う。配布ジョブは署名・ビルド・Firebase へのアップロードに専念する。

Android レッグでは Gradle（`~/.gradle/caches` と `~/.gradle/wrapper`）と Android NDK（`$ANDROID_HOME/ndk`）を `actions/cache` でキャッシュする。キーには Gradle 設定・`pubspec.lock`・Flutter 版（NDK は `flutter.ndkVersion` に追随するため）を含める。

versionName は `pubspec.yaml` のままにする。versionCode / CFBundleVersion は GitHub Actions の run number にする。Android の release 署名は同じ upload keystore を使い、配布済みの APK を上書き更新できるようにする。debug 署名は release に使わない。

keystore とパスワードは、アイテム `CogLog_develop` に置く。Actions は次の参照を読み、標準出力へパスワードを出さずに `app/android/key.properties` を書く。

- `op://AppDevelopment/CogLog_develop/upload-keystore.jks`
- `op://AppDevelopment/CogLog_develop/storePassword`
- `op://AppDevelopment/CogLog_develop/keyPassword`
- `op://AppDevelopment/CogLog_develop/keyAlias`

`storeFile` は `app/android/app` から `../../../secrets/android/upload-keystore.jks` を指す。keystore、`key.properties`、パスワードは Git に入れない。

keystore がまだ無いときは、リポジトリの外で一度だけ作り、同じアイテムへファイル添付する。`keyAlias` に入れる別名は、このコマンドの `-alias` と揃える。

```bash
keytool -genkeypair -v \
  -keystore upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

`storePassword` と `keyPassword` は、そのときに入力したパスワードである。同じファイルを後から作り直すと、すでに配布した APK を上書き更新できなくなる。

iOS の配布用証明書（`.p12`）と Ad Hoc プロファイル（`.mobileprovision`）も、リポジトリの外で用意してフレーバー別アイテムへ添付する。**同じ Apple Distribution 証明書**でプロファイルを発行し、その証明書を `.p12` として添付する。証明書やプロファイルを差し替えると、端末側の信頼やインストール条件が変わることがある。
