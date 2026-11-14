import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:riverpod/riverpod.dart';

import 'meter_reading_engine_kind.dart';

/// 1 エンジンの読み取り窓口。
///
/// Example:
/// ```dart
/// await engine.isAvailable;
/// ```
abstract interface class MeterReadingEngine {
  /// エンジン種別。
  MeterReadingEngineKind get kind;

  /// 利用可能か。
  Future<bool> get isAvailable;

  /// [photoBytes] を読む。
  ///
  /// Example:
  /// ```dart
  /// await engine.read(Uint8List(0));
  /// ```
  Future<MeterReadingValues> read(Uint8List photoBytes);
}

/// 読み取りエンジン列の注入点。未接続のときは失敗する。
///
/// 実リストの組み立ては injection 側で行う。
///
/// Example:
/// ```dart
/// meterReadingEnginesProvider;
/// ```
final meterReadingEnginesProvider = Provider<List<MeterReadingEngine>>(
  (ref) => throw UnimplementedError('meterReadingEnginesProvider'),
);

/// LLM メーター読み取りエンジンの注入点。
///
/// Example:
/// ```dart
/// meterReadingLlmEngineProvider;
/// ```
final meterReadingLlmEngineProvider = Provider<MeterReadingEngine>(
  (ref) => throw UnimplementedError('meterReadingLlmEngineProvider'),
);
