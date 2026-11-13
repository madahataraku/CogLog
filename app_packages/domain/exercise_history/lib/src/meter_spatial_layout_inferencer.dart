import 'dart:math' as math;

import 'meter_duration_parser.dart';
import 'meter_ocr_token.dart';
import 'meter_reading_values.dart';

/// 座標付き OCR トークンからメーター計測値を推定する。
///
/// 平均速度は常に未取得（呼び出し側で距離÷時間）。
///
/// Example:
/// ```dart
/// MeterSpatialLayoutInferencer.infer(const [
///   MeterOcrToken(text: '距離', left: 0.1, top: 0.1, width: 0.2, height: 0.05),
///   MeterOcrToken(text: '12.3', left: 0.1, top: 0.18, width: 0.2, height: 0.06),
/// ]);
/// ```
abstract final class MeterSpatialLayoutInferencer {
  static const _distanceLabels = {
    'distance_km',
    'distance',
    'dist',
    '走行距離',
    '距離',
  };
  static const _calorieLabels = {
    'calories_kcal',
    'calorie',
    'calories',
    'cal',
    'kcal',
    '消費カロリー',
    'カロリー',
    '消費',
  };
  static const _timeLabels = {'duration', 'time', '運動時間', '時間'};
  static const _speedLabels = {
    'average_speed',
    'average_speed_kmh',
    'speed',
    '平均速度',
    '速度',
  };
  static const _speedUnits = {'km/h', 'kmh'};

  /// [tokens] から読めた項目だけを返す。
  ///
  /// Example:
  /// ```dart
  /// MeterSpatialLayoutInferencer.infer(const []);
  /// ```
  static MeterReadingValues infer(List<MeterOcrToken> tokens) {
    if (tokens.isEmpty) {
      return const MeterReadingValues();
    }
    final classified = [
      for (var i = 0; i < tokens.length; i++) _classifyAt(i, tokens[i]),
    ];
    final used = <int>{};

    final distance = _linkNumericField(
      classified: classified,
      used: used,
      anchorKinds: {_Kind.distanceLabel, _Kind.distanceUnit},
      valueKinds: {_Kind.bareNumber, _Kind.distanceValueWithUnit},
      unitKind: _Kind.distanceValueWithUnit,
    );
    final calories = _linkNumericField(
      classified: classified,
      used: used,
      anchorKinds: {_Kind.calorieLabel, _Kind.calorieUnit},
      valueKinds: {_Kind.bareNumber, _Kind.calorieValueWithUnit},
      unitKind: _Kind.calorieValueWithUnit,
    );
    final duration = _resolveDuration(classified, used);

    return MeterReadingValues(
      distanceKm: distance,
      duration: duration,
      caloriesKcal: calories,
    );
  }

  static Duration? _resolveDuration(
    List<_Classified> classified,
    Set<int> used,
  ) {
    final colonOnly = [
      for (final c in classified)
        if (c.kind == _Kind.durationValue && !used.contains(c.index)) c,
    ];
    if (colonOnly.length == 1) {
      used.add(colonOnly.single.index);
      return colonOnly.single.duration;
    }
    return _linkDurationWithAnchors(classified, used);
  }

  static Duration? _linkDurationWithAnchors(
    List<_Classified> classified,
    Set<int> used,
  ) {
    final anchors = [
      for (final c in classified)
        if (c.kind == _Kind.timeLabel && !used.contains(c.index)) c,
    ];
    if (anchors.isEmpty) {
      return null;
    }
    final values = <_Classified>[];
    for (final c in classified) {
      if (used.contains(c.index)) {
        continue;
      }
      if (c.kind == _Kind.durationValue) {
        values.add(c);
      }
    }
    if (values.isEmpty) {
      return null;
    }
    final pair = _bestUniquePair(anchors, values);
    if (pair == null) {
      return null;
    }
    used
      ..add(pair.$1.index)
      ..add(pair.$2.index);
    return pair.$2.duration;
  }

  static double? _linkNumericField({
    required List<_Classified> classified,
    required Set<int> used,
    required Set<_Kind> anchorKinds,
    required Set<_Kind> valueKinds,
    required _Kind unitKind,
  }) {
    final anchors = [
      for (final c in classified)
        if (anchorKinds.contains(c.kind) && !used.contains(c.index)) c,
    ];
    final values = [
      for (final c in classified)
        if (valueKinds.contains(c.kind) && !used.contains(c.index)) c,
    ];

    if (anchors.isEmpty) {
      final selfContained = [
        for (final c in classified)
          if (c.kind == unitKind && !used.contains(c.index)) c,
      ];
      if (selfContained.length == 1) {
        used.add(selfContained.single.index);
        return selfContained.single.number;
      }
      return null;
    }
    if (values.isEmpty) {
      return null;
    }
    final pair = _bestUniquePair(anchors, values);
    if (pair == null) {
      return null;
    }
    used
      ..add(pair.$1.index)
      ..add(pair.$2.index);
    return pair.$2.number;
  }

  static (_Classified, _Classified)? _bestUniquePair(
    List<_Classified> anchors,
    List<_Classified> values,
  ) {
    final scored = <(double, bool, _Classified, _Classified)>[];
    for (final a in anchors) {
      for (final v in values) {
        scored.add((_distance(a.token, v.token), _sameRow(a.token, v.token), a, v));
      }
    }
    scored.sort((x, y) {
      if (x.$2 != y.$2) {
        return x.$2 ? -1 : 1;
      }
      return x.$1.compareTo(y.$1);
    });
    if (scored.isEmpty) {
      return null;
    }
    final best = scored.first;
    final rivalsForAnchor = [
      for (final s in scored)
        if (identical(s.$3, best.$3)) s,
    ];
    if (rivalsForAnchor.length >= 2 &&
        rivalsForAnchor[1].$1 <= rivalsForAnchor[0].$1 * 1.25) {
      return null;
    }
    return (best.$3, best.$4);
  }

  static double _distance(MeterOcrToken a, MeterOcrToken b) {
    final dx = a.centerX - b.centerX;
    final dy = a.centerY - b.centerY;
    return math.sqrt(dx * dx + dy * dy);
  }

  static bool _sameRow(MeterOcrToken a, MeterOcrToken b) {
    final threshold = math.max(0.06, math.max(a.height, b.height));
    return (a.centerY - b.centerY).abs() <= threshold;
  }

  static _Classified _classifyAt(int index, MeterOcrToken token) {
    final t = _normalize(token.text);
    if (_speedLabels.contains(t) || _speedUnits.contains(t)) {
      return _Classified(index: index, token: token, kind: _Kind.speedIgnore);
    }
    if (_distanceLabels.contains(t)) {
      return _Classified(index: index, token: token, kind: _Kind.distanceLabel);
    }
    if (_calorieLabels.contains(t)) {
      return _Classified(index: index, token: token, kind: _Kind.calorieLabel);
    }
    if (_timeLabels.contains(t)) {
      return _Classified(index: index, token: token, kind: _Kind.timeLabel);
    }
    if (t == 'km') {
      return _Classified(index: index, token: token, kind: _Kind.distanceUnit);
    }
    if (t == 'kcal' || t == 'cal') {
      return _Classified(index: index, token: token, kind: _Kind.calorieUnit);
    }
    final colon = MeterDurationParser.parseColonOnly(token.text);
    if (colon != null) {
      return _Classified(
        index: index,
        token: token,
        kind: _Kind.durationValue,
        duration: colon,
      );
    }
    final embedded = _parseNumberWithOptionalUnit(t);
    if (embedded != null) {
      final (value, unit) = embedded;
      if (unit == 'km/h' || unit == 'kmh') {
        return _Classified(index: index, token: token, kind: _Kind.speedIgnore);
      }
      if (unit == 'km') {
        return _Classified(
          index: index,
          token: token,
          kind: _Kind.distanceValueWithUnit,
          number: value,
        );
      }
      if (unit == 'kcal' || unit == 'cal') {
        return _Classified(
          index: index,
          token: token,
          kind: _Kind.calorieValueWithUnit,
          number: value,
        );
      }
      return _Classified(
        index: index,
        token: token,
        kind: _Kind.bareNumber,
        number: value,
      );
    }
    return _Classified(index: index, token: token, kind: _Kind.other);
  }

  static String _normalize(String raw) {
    final buffer = StringBuffer();
    for (final unit in raw.runes) {
      if (unit >= 0xff10 && unit <= 0xff19) {
        buffer.writeCharCode(0x30 + (unit - 0xff10));
        continue;
      }
      buffer.writeCharCode(unit);
    }
    return buffer
        .toString()
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), '');
  }

  static (double, String?)? _parseNumberWithOptionalUnit(String normalized) {
    final match = RegExp(
      r'^-?(\d+(?:\.\d+)?)(km/h|kmh|km|kcal|cal)?$',
    ).firstMatch(normalized);
    if (match == null) {
      return null;
    }
    final value = double.tryParse(match.group(1)!);
    if (value == null || !value.isFinite || value < 0 || value > 1000000) {
      return null;
    }
    return (value, match.group(2));
  }
}

enum _Kind {
  distanceLabel,
  calorieLabel,
  timeLabel,
  distanceUnit,
  calorieUnit,
  bareNumber,
  distanceValueWithUnit,
  calorieValueWithUnit,
  durationValue,
  speedIgnore,
  other,
}

final class _Classified {
  const _Classified({
    required this.index,
    required this.token,
    required this.kind,
    this.number,
    this.duration,
  });

  final int index;
  final MeterOcrToken token;
  final _Kind kind;
  final double? number;
  final Duration? duration;
}
