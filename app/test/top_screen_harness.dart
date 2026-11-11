import 'dart:io';

import 'package:data_database/data_database.dart';
import 'package:data_injection/data_injection.dart';
import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';
import 'package:infra_health_body_metrics_testing/infra_health_body_metrics_testing.dart';
import 'package:infra_injection/infra_injection.dart';
import 'package:infra_meter_photo_testing/infra_meter_photo_testing.dart';
import 'package:infra_on_device_llm_testing/infra_on_device_llm_testing.dart';
import 'package:screen_injection/screen_injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usecase_generate_top_advice_impl/usecase_generate_top_advice_impl.dart';
import 'package:usecase_injection/usecase_injection.dart';

import 'package:app/main.dart';

const _advisorTones = ['fun', 'confused', 'happy', 'realized'];

/// トップ画面を、テスト用の履歴付きで起動する。
Future<ScreenGraph> pumpTopScreen(
  WidgetTester tester, {
  List<ExerciseHistory> histories = const [],
  SharedPreferences? preferences,
}) async {
  final stored = preferences ?? await _newPreferences();
  final documents = Directory.systemTemp.createTempSync('coglog_test_');
  addTearDown(() {
    if (documents.existsSync()) {
      documents.deleteSync(recursive: true);
    }
  });
  final database = openMemoryDatabase();
  addTearDown(database.close);
  final screens = ScreenGraph();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...dataRepositoryOverrides(
          preferences: stored,
          database: database,
          documentsDirectory: documents,
          histories: FixedExerciseHistoryRepository(histories),
        ),
        // Widget テストの既定 OS は Android。本番 DI のオンデバイス LLM は
        // readiness がチャネル待ちで止まるため、固定 Fake に差し替える。
        // メーター写真も実カメラ初期化で progress が回り続けるため Fake にする。
        // ヘルス読取もプラグイン未実装のため Unavailable にする。
        ...infraOverrides(
          onDeviceLlm: FakeOnDeviceLlm(available: false),
          meterPhotoSource: FakeMeterPhotoSource(),
          healthBodyMetricsSource: FakeHealthBodyMetricsSource(
            status: HealthBodyPermissionStatus.denied,
          ),
        ),
        ...usecaseOverrides(
          adviceTemplatePicker: const FixedAdviceTemplatePicker(),
        ),
        ...screenOverrides(screens),
      ],
      child: Application(router: screens.router),
    ),
  );
  await tester.pumpAndSettle();
  await _precacheAdvisorImages(tester);
  await tester.pumpAndSettle();
  return screens;
}

/// アドバイザー PNG を先に読み、Golden のレースを防ぐ。
Future<void> _precacheAdvisorImages(WidgetTester tester) async {
  final context = tester.element(find.byType(Application));
  await tester.runAsync(() async {
    for (final tone in _advisorTones) {
      await precacheImage(
        AssetImage('assets/advisor/$tone.png', package: 'screen_feature_top'),
        context,
      );
    }
  });
}

Future<SharedPreferences> _newPreferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

ExerciseHistory rideNow({double distanceKm = 1, double caloriesKcal = 1.25}) {
  const id = '11111111-1111-4111-8111-111111111111';
  final now = DateTime.now();
  return ExerciseHistory(
    id: id,
    savedAt: now,
    creationStartedAt: now,
    capturedAt: now,
    recordedAt: now,
    recordedAtManuallySet: false,
    distanceKm: distanceKm,
    duration: const Duration(minutes: 30),
    caloriesKcal: caloriesKcal,
    averageSpeedKmh: 1,
    photoRelativePath: 'exercise_histories/$id/meter.jpg',
  );
}
