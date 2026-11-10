import 'package:data_database/data_database.dart';
import 'package:data_injection/data_injection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:infra_injection/infra_injection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_injection/screen_injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:usecase_injection/usecase_injection.dart';

import 'package:app_runner/app_runner.dart';

import 'src/exercise_reminder_bootstrap.dart';
import 'theme/theme.dart';

/// CogLog を起動する。
///
/// 保存済みの指標を読み、ホームを最初に出す。
///
/// Example:
/// ```dart
/// Future<void> main() async {
///   await launchCogLog();
/// }
/// ```
Future<void> main() => launchCogLog();

/// 依存を組んで [Application] を起動する。
///
/// Example:
/// ```dart
/// await launchCogLog();
/// ```
Future<void> launchCogLog() async {
  WidgetsFlutterBinding.ensureInitialized();
  await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
  final preferences = await SharedPreferences.getInstance();
  final documents = await getApplicationDocumentsDirectory();
  final database = openDocumentsDatabase(documents);
  final screens = ScreenGraph();
  final container = ProviderContainer(
    overrides: [
      ...dataRepositoryOverrides(
        preferences: preferences,
        database: database,
        documentsDirectory: documents,
      ),
      ...infraOverrides(),
      ...usecaseOverrides(),
      ...screenOverrides(screens),
    ],
  );
  await ExerciseReminderBootstrap(
    container: container,
    navigation: screens.navigation,
  ).run();
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: Application(router: screens.router),
    ),
  );
}

/// Forui テーマとローカライゼーションを束ねたアプリケーション。
///
/// 明暗はプラットフォームの明るさに追従する。文言は [L10nHelper] の ja / en。
///
/// Example:
/// ```dart
/// Application(router: router);
/// ```
class Application extends StatelessWidget {
  /// [router] をルートにする。
  ///
  /// Example:
  /// ```dart
  /// Application(router: router);
  /// ```
  const Application({required this.router, super.key});

  /// ホームから始まる遷移。
  final GoRouter router;

  /// [FTheme] と [L10nHelper] を [MaterialApp] に載せる。
  ///
  /// Example:
  /// ```dart
  /// Application(router: router);
  /// ```
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    routerConfig: router,
    supportedLocales: L10nHelper.supportedLocales,
    // material_ui の MaterialApp は英語だけの Default*Localizations を足す。
    // ja を含む delegate を先に渡す。
    localizationsDelegates: const [
      ...appLocalizationsDelegates,
      FLocalizations.delegate,
    ],
    theme: lightTheme.toApproximateMaterialTheme(),
    darkTheme: darkTheme.toApproximateMaterialTheme(),
    builder: (context, child) => FTheme(
      data: Theme.brightnessOf(context) == Brightness.light
          ? lightTheme
          : darkTheme,
      child: FToaster(child: FTooltipGroup(child: child!)),
    ),
  );
}
