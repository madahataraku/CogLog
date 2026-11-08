import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ja'),
    Locale('en'),
  ];

  /// 現在の回数
  ///
  /// In ja, this message translates to:
  /// **'回数 {count}'**
  String app_count(String count);

  /// カウントを増やすボタン
  ///
  /// In ja, this message translates to:
  /// **'増やす'**
  String get app_increase;

  /// アプリケーション名
  ///
  /// In ja, this message translates to:
  /// **'CogLog'**
  String get foundation_resources_app_name;

  /// リスト項目の消費カロリー
  ///
  /// In ja, this message translates to:
  /// **'消費カロリー'**
  String get screen_feature_exercise_history_calories;

  /// 消費カロリーの単位
  ///
  /// In ja, this message translates to:
  /// **'kcal'**
  String get screen_feature_exercise_history_calories_unit;

  /// リスト項目の作成開始日時
  ///
  /// In ja, this message translates to:
  /// **'作成開始日時'**
  String get screen_feature_exercise_history_created_at;

  /// 平均速度のラベル
  ///
  /// In ja, this message translates to:
  /// **'平均速度'**
  String get screen_feature_exercise_history_detail_average_speed;

  /// 平均速度の単位
  ///
  /// In ja, this message translates to:
  /// **'km/h'**
  String get screen_feature_exercise_history_detail_average_speed_unit;

  /// 不在時の戻るボタン
  ///
  /// In ja, this message translates to:
  /// **'戻る'**
  String get screen_feature_exercise_history_detail_back;

  /// 消費カロリーのラベル
  ///
  /// In ja, this message translates to:
  /// **'消費カロリー'**
  String get screen_feature_exercise_history_detail_calories;

  /// 消費カロリーの単位
  ///
  /// In ja, this message translates to:
  /// **'kcal'**
  String get screen_feature_exercise_history_detail_calories_unit;

  /// 撮影日時のラベル
  ///
  /// In ja, this message translates to:
  /// **'撮影日時'**
  String get screen_feature_exercise_history_detail_captured_at;

  /// 作成開始日時のラベル
  ///
  /// In ja, this message translates to:
  /// **'作成開始日時'**
  String get screen_feature_exercise_history_detail_created_at;

  /// 走行距離のラベル
  ///
  /// In ja, this message translates to:
  /// **'走行距離'**
  String get screen_feature_exercise_history_detail_distance;

  /// 走行距離の単位
  ///
  /// In ja, this message translates to:
  /// **'km'**
  String get screen_feature_exercise_history_detail_distance_unit;

  /// 運動時間のラベル
  ///
  /// In ja, this message translates to:
  /// **'運動時間'**
  String get screen_feature_exercise_history_detail_duration;

  /// 記録日時の手変更サフィックス
  ///
  /// In ja, this message translates to:
  /// **'（編集済み）'**
  String get screen_feature_exercise_history_detail_edited;

  /// 詳細の読込失敗
  ///
  /// In ja, this message translates to:
  /// **'詳細を読み込めませんでした'**
  String get screen_feature_exercise_history_detail_error;

  /// 不在
  ///
  /// In ja, this message translates to:
  /// **'この運動履歴はありません'**
  String get screen_feature_exercise_history_detail_missing;

  /// 写真のラベル
  ///
  /// In ja, this message translates to:
  /// **'メーターパネル写真'**
  String get screen_feature_exercise_history_detail_photo;

  /// 写真の失敗表示
  ///
  /// In ja, this message translates to:
  /// **'写真を表示できません'**
  String get screen_feature_exercise_history_detail_photo_error;

  /// 記録日時のラベル
  ///
  /// In ja, this message translates to:
  /// **'記録日時'**
  String get screen_feature_exercise_history_detail_recorded_at;

  /// 再試行ボタン
  ///
  /// In ja, this message translates to:
  /// **'再試行'**
  String get screen_feature_exercise_history_detail_retry;

  /// 保存日時のラベル
  ///
  /// In ja, this message translates to:
  /// **'保存日時'**
  String get screen_feature_exercise_history_detail_saved_at;

  /// 画面タイトル
  ///
  /// In ja, this message translates to:
  /// **'運動履歴詳細'**
  String get screen_feature_exercise_history_detail_title;

  /// リスト項目の走行距離
  ///
  /// In ja, this message translates to:
  /// **'走行距離'**
  String get screen_feature_exercise_history_distance;

  /// 走行距離の単位
  ///
  /// In ja, this message translates to:
  /// **'km'**
  String get screen_feature_exercise_history_distance_unit;

  /// リスト項目の運動時間
  ///
  /// In ja, this message translates to:
  /// **'運動時間'**
  String get screen_feature_exercise_history_duration;

  /// 空リストの案内
  ///
  /// In ja, this message translates to:
  /// **'この月の運動履歴がありません。メーター記録から、メーターパネルの撮影または手入力で運動履歴を作成してください。'**
  String get screen_feature_exercise_history_empty;

  /// 一覧の読込失敗
  ///
  /// In ja, this message translates to:
  /// **'運動履歴を読み込めませんでした'**
  String get screen_feature_exercise_history_error;

  /// 追加読込の失敗
  ///
  /// In ja, this message translates to:
  /// **'続きを読み込めませんでした'**
  String get screen_feature_exercise_history_load_more_error;

  /// 月セレクタのラベル
  ///
  /// In ja, this message translates to:
  /// **'{year}年{month}月'**
  String screen_feature_exercise_history_month_label(String year, String month);

  /// 再試行ボタン
  ///
  /// In ja, this message translates to:
  /// **'再試行'**
  String get screen_feature_exercise_history_retry;

  /// 画面タイトル
  ///
  /// In ja, this message translates to:
  /// **'運動履歴'**
  String get screen_feature_exercise_history_title;

  /// 一日あたり消費カロリーの欄
  ///
  /// In ja, this message translates to:
  /// **'消費カロリー'**
  String get screen_feature_goal_settings_calories_label;

  /// 消費カロリーの単位
  ///
  /// In ja, this message translates to:
  /// **'kcal'**
  String get screen_feature_goal_settings_calories_unit;

  /// 一日あたり走行距離の欄
  ///
  /// In ja, this message translates to:
  /// **'走行距離'**
  String get screen_feature_goal_settings_distance_label;

  /// 走行距離の単位
  ///
  /// In ja, this message translates to:
  /// **'km'**
  String get screen_feature_goal_settings_distance_unit;

  /// 一日あたり運動時間の欄
  ///
  /// In ja, this message translates to:
  /// **'運動時間'**
  String get screen_feature_goal_settings_duration_label;

  /// 運動時間の時
  ///
  /// In ja, this message translates to:
  /// **'時間'**
  String get screen_feature_goal_settings_hours_label;

  /// 運動時間の分
  ///
  /// In ja, this message translates to:
  /// **'分'**
  String get screen_feature_goal_settings_minutes_label;

  /// 目標を保存するボタン
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get screen_feature_goal_settings_save;

  /// 永続化失敗の通知
  ///
  /// In ja, this message translates to:
  /// **'目標を保存できませんでした'**
  String get screen_feature_goal_settings_save_failed;

  /// 入力不正の通知
  ///
  /// In ja, this message translates to:
  /// **'入力内容を確認してください'**
  String get screen_feature_goal_settings_save_invalid_input;

  /// 保存成功の通知
  ///
  /// In ja, this message translates to:
  /// **'目標を保存しました'**
  String get screen_feature_goal_settings_save_success;

  /// 運動時間の秒
  ///
  /// In ja, this message translates to:
  /// **'秒'**
  String get screen_feature_goal_settings_seconds_label;

  /// 画面タイトル
  ///
  /// In ja, this message translates to:
  /// **'目標設定'**
  String get screen_feature_goal_settings_title;

  /// 未設定の説明
  ///
  /// In ja, this message translates to:
  /// **'未設定の欄は空のまま保存できます'**
  String get screen_feature_goal_settings_unset_hint;

  /// ボトムナビ
  ///
  /// In ja, this message translates to:
  /// **'運動履歴'**
  String get screen_feature_main_nav_exercise_history;

  /// ボトムナビ
  ///
  /// In ja, this message translates to:
  /// **'目標設定'**
  String get screen_feature_main_nav_goal_settings;

  /// ボトムナビ
  ///
  /// In ja, this message translates to:
  /// **'ホーム'**
  String get screen_feature_main_nav_home;

  /// ボトムナビ
  ///
  /// In ja, this message translates to:
  /// **'メーター記録'**
  String get screen_feature_main_nav_meter_capture;

  /// 入力ラベル
  ///
  /// In ja, this message translates to:
  /// **'平均速度 (km/h)'**
  String get screen_feature_meter_capture_average_speed;

  /// 2→1
  ///
  /// In ja, this message translates to:
  /// **'戻る'**
  String get screen_feature_meter_capture_back;

  /// 入力ラベル
  ///
  /// In ja, this message translates to:
  /// **'消費カロリー (kcal)'**
  String get screen_feature_meter_capture_calories;

  /// カメラ撮影
  ///
  /// In ja, this message translates to:
  /// **'撮影する'**
  String get screen_feature_meter_capture_capture_photo;

  /// 入力ラベル
  ///
  /// In ja, this message translates to:
  /// **'走行距離 (km)'**
  String get screen_feature_meter_capture_distance;

  /// 運動時間・時
  ///
  /// In ja, this message translates to:
  /// **'時間'**
  String get screen_feature_meter_capture_duration_hours;

  /// 運動時間・分
  ///
  /// In ja, this message translates to:
  /// **'分'**
  String get screen_feature_meter_capture_duration_minutes;

  /// 運動時間・秒
  ///
  /// In ja, this message translates to:
  /// **'秒'**
  String get screen_feature_meter_capture_duration_seconds;

  /// 設定アプリ導線
  ///
  /// In ja, this message translates to:
  /// **'設定を開く'**
  String get screen_feature_meter_capture_open_settings;

  /// カメラ権限拒否
  ///
  /// In ja, this message translates to:
  /// **'カメラの許可が必要です'**
  String get screen_feature_meter_capture_permission_camera;

  /// ライブラリ権限拒否
  ///
  /// In ja, this message translates to:
  /// **'写真へのアクセス許可が必要です'**
  String get screen_feature_meter_capture_permission_library;

  /// 写真ライブラリ
  ///
  /// In ja, this message translates to:
  /// **'ライブラリから選ぶ'**
  String get screen_feature_meter_capture_pick_library;

  /// 読み取り待機
  ///
  /// In ja, this message translates to:
  /// **'読み取り中…'**
  String get screen_feature_meter_capture_reading;

  /// 記録日時
  ///
  /// In ja, this message translates to:
  /// **'記録日時'**
  String get screen_feature_meter_capture_recorded_at;

  /// 登録ボタン
  ///
  /// In ja, this message translates to:
  /// **'登録'**
  String get screen_feature_meter_capture_save;

  /// 保存失敗
  ///
  /// In ja, this message translates to:
  /// **'保存に失敗しました'**
  String get screen_feature_meter_capture_save_failed;

  /// 画面タイトル
  ///
  /// In ja, this message translates to:
  /// **'メーター記録'**
  String get screen_feature_meter_capture_title;

  /// 目標達成率セクションの見出し
  ///
  /// In ja, this message translates to:
  /// **'目標達成率'**
  String get screen_feature_top_achievement_title;

  /// 実績のラベル
  ///
  /// In ja, this message translates to:
  /// **'実績'**
  String get screen_feature_top_actual_label;

  /// 履歴0件のワンポイント
  ///
  /// In ja, this message translates to:
  /// **'今日はまだ運動の記録がありません。無理のないペースで始めましょう。'**
  String get screen_feature_top_advice_no_exercise;

  /// LLM不可時の定型1
  ///
  /// In ja, this message translates to:
  /// **'水分をこまめに取って、無理のないペースを保ちましょう。'**
  String get screen_feature_top_advice_template_1;

  /// LLM不可時の定型2
  ///
  /// In ja, this message translates to:
  /// **'よく動けました。回復のためにも休息を大切にしましょう。'**
  String get screen_feature_top_advice_template_2;

  /// LLM不可時の定型3
  ///
  /// In ja, this message translates to:
  /// **'小さな積み重ねが続きます。今日も自分のペースで。'**
  String get screen_feature_top_advice_template_3;

  /// アドバイスキャラクターの代替テキスト
  ///
  /// In ja, this message translates to:
  /// **'アドバイザー'**
  String get screen_feature_top_advisor_semantics;

  /// 指標
  ///
  /// In ja, this message translates to:
  /// **'消費カロリー'**
  String get screen_feature_top_calories;

  /// 消費カロリーの単位
  ///
  /// In ja, this message translates to:
  /// **'kcal'**
  String get screen_feature_top_calories_unit;

  /// 指標
  ///
  /// In ja, this message translates to:
  /// **'走行距離'**
  String get screen_feature_top_distance;

  /// 走行距離の単位
  ///
  /// In ja, this message translates to:
  /// **'km'**
  String get screen_feature_top_distance_unit;

  /// 指標
  ///
  /// In ja, this message translates to:
  /// **'運動時間'**
  String get screen_feature_top_duration;

  /// 目標のラベル
  ///
  /// In ja, this message translates to:
  /// **'目標'**
  String get screen_feature_top_goal_label;

  /// 集計期間
  ///
  /// In ja, this message translates to:
  /// **'今月'**
  String get screen_feature_top_this_month;

  /// 集計期間
  ///
  /// In ja, this message translates to:
  /// **'今週'**
  String get screen_feature_top_this_week;

  /// 集計期間
  ///
  /// In ja, this message translates to:
  /// **'本日'**
  String get screen_feature_top_today;

  /// 目標未設定時の設定促進
  ///
  /// In ja, this message translates to:
  /// **'目標設定で一日あたりの目標を設定しましょう'**
  String get screen_feature_top_unset_prompt;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'ja':
      return L10nJa();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
