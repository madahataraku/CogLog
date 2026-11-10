import 'package:infra_app_runtime_info/infra_app_runtime_info.dart';
import 'package:usecase_load_app_runtime_info/usecase_load_app_runtime_info.dart';

/// [AppRuntimeInfoReader] を呼ぶ実装。
///
/// Example:
/// ```dart
/// LoadAppRuntimeInfoUsecaseImpl(reader: reader);
/// ```
final class LoadAppRuntimeInfoUsecaseImpl implements LoadAppRuntimeInfoUsecase {
  /// [reader] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// LoadAppRuntimeInfoUsecaseImpl(reader: reader);
  /// ```
  const LoadAppRuntimeInfoUsecaseImpl({required this.reader});

  /// 実行情報の読み出し口。
  final AppRuntimeInfoReader reader;

  /// 例外時は null を返す。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  @override
  Future<AppRuntimeInfo?> execute() async {
    try {
      return await reader.read();
    } catch (_) {
      return null;
    }
  }
}
