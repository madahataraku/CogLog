import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:screen_feature_achievement/src/viewmodel/achievement_screen_view_model.dart';
import 'package:screen_feature_achievement/src/viewmodel/state/achievement_screen_state.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';

final class _Nav implements ScreenNavigation {
  var popCalls = 0;

  @override
  void openExerciseHistoryDetail({required String id}) {}

  @override
  void openAppSettings() {}

  @override
  void openAchievements() {}

  @override
  void openDebug() {}

  @override
  void openNotificationSettings() {}

  @override
  void openOssLicenses() {}

  @override
  void openOssLicenseDetail({required String packageName}) {}

  @override
  void pop() {
    popCalls += 1;
  }

  @override
  void goToHomeTab() {}
}

final class _FakeLoad implements LoadAchievementsUsecase {
  _FakeLoad({this.result});

  LoadAchievementsResult? result;
  var calls = 0;

  @override
  Future<LoadAchievementsResult> execute(
    LoadAchievementsRequest request,
  ) async {
    calls += 1;
    return result ?? const LoadAchievementsFailed();
  }
}

void main() {
  test('読込失敗後の再試行で ready になる', () async {
    final load = _FakeLoad(result: const LoadAchievementsFailed());
    final nav = _Nav();
    final container = ProviderContainer(
      overrides: [
        screenNavigationProvider.overrideWith((ref) => nav),
        LoadAchievementsUsecase.provider.overrideWith((ref) => load),
      ],
    );
    addTearDown(container.dispose);

    final viewModel = container.read(AchievementScreenViewModel.provider);
    expect(viewModel.state.state, isA<AchievementScreenLoading>());

    await viewModel.onInitialize();
    expect(viewModel.state.state, isA<AchievementScreenFailed>());
    expect(load.calls, 1);

    load.result = const LoadAchievementsSuccess([
      AchievementRow(
        id: 'first_record',
        unlocked: true,
        current: 1,
        target: 1,
        progressRatio: 1,
        binaryProgress: true,
      ),
    ]);

    await viewModel.onRetry();
    expect(load.calls, 2);
    final ready = viewModel.state.state;
    expect(ready, isA<AchievementScreenReady>());
    expect((ready as AchievementScreenReady).rows, hasLength(1));
    expect(ready.rows.first.id, 'first_record');
  });

  test('読込成功で ready になる', () async {
    final load = _FakeLoad(
      result: const LoadAchievementsSuccess([
        AchievementRow(
          id: 'streak_3',
          unlocked: false,
          current: 1,
          target: 3,
          progressRatio: 1 / 3,
          binaryProgress: false,
        ),
      ]),
    );
    final container = ProviderContainer(
      overrides: [
        screenNavigationProvider.overrideWith((ref) => _Nav()),
        LoadAchievementsUsecase.provider.overrideWith((ref) => load),
      ],
    );
    addTearDown(container.dispose);

    final viewModel = container.read(AchievementScreenViewModel.provider);
    await viewModel.onInitialize();
    final ready = viewModel.state.state;
    expect(ready, isA<AchievementScreenReady>());
    expect(
      (ready as AchievementScreenReady).rows.single.progressRatio,
      closeTo(1 / 3, 1e-9),
    );
  });

  test('ready 後の再初期化でも loading 経由で ready に戻る', () async {
    final load = _FakeLoad(
      result: const LoadAchievementsSuccess([
        AchievementRow(
          id: 'first_record',
          unlocked: true,
          current: 1,
          target: 1,
          progressRatio: 1,
          binaryProgress: true,
        ),
      ]),
    );
    final container = ProviderContainer(
      overrides: [
        screenNavigationProvider.overrideWith((ref) => _Nav()),
        LoadAchievementsUsecase.provider.overrideWith((ref) => load),
      ],
    );
    addTearDown(container.dispose);

    final viewModel = container.read(AchievementScreenViewModel.provider);
    await viewModel.onInitialize();
    expect(viewModel.state.state, isA<AchievementScreenReady>());
    expect(load.calls, 1);

    final second = viewModel.onInitialize();
    await Future<void>.value();
    expect(viewModel.state.state, isA<AchievementScreenLoading>());
    await second;
    expect(viewModel.state.state, isA<AchievementScreenReady>());
    expect(load.calls, 2);
  });
}
