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

  /// [tokens] の分類件数だけを返す（本文・数値は含まない）。
  ///
  /// Example:
  /// ```dart
  /// MeterSpatialLayoutInferencer.classifyKindCounts(const []);
  /// ```
  static Map<String, int> classifyKindCounts(List<MeterOcrToken> tokens) {
    final counts = <String, int>{};
    for (var i = 0; i < tokens.length; i++) {
      final name = _classifyAt(i, tokens[i]).kind.name;
      counts[name] = (counts[name] ?? 0) + 1;
    }
    return counts;
  }

  /// `other` のうち桁を含む件数。OCR が数値を取りこぼしたかの切り分け用。
  ///
  /// Example:
  /// ```dart
  /// MeterSpatialLayoutInferencer.countOtherWithDigits(const []);
  /// ```
  static int countOtherWithDigits(List<MeterOcrToken> tokens) {
    var count = 0;
    for (var i = 0; i < tokens.length; i++) {
      final classified = _classifyAt(i, tokens[i]);
      if (classified.kind != _Kind.other) {
        continue;
      }
      if (RegExp(r'\d').hasMatch(_normalize(classified.token.text))) {
        count += 1;
      }
    }
    return count;
  }

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
    _consumeSpeedLinkedNumbers(classified, used);

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

  /// 速度ラベル／単位に一意に結び付く裸数値を候補から外す。
  ///
  /// Example:
  /// ```dart
  /// _consumeSpeedLinkedNumbers(classified, used);
  /// ```
  static void _consumeSpeedLinkedNumbers(
    List<_Classified> classified,
    Set<int> used,
  ) {
    while (true) {
      final speedAnchors = [
        for (final c in classified)
          if (c.kind == _Kind.speedIgnore && !used.contains(c.index)) c,
      ];
      final otherAnchors = [
        for (final c in classified)
          if (!used.contains(c.index) &&
              (c.kind == _Kind.distanceLabel ||
                  c.kind == _Kind.distanceUnit ||
                  c.kind == _Kind.calorieLabel ||
                  c.kind == _Kind.calorieUnit ||
                  c.kind == _Kind.timeLabel))
            c,
      ];
      final bareNumbers = [
        for (final c in classified)
          if (c.kind == _Kind.bareNumber &&
              !used.contains(c.index) &&
              _isSpeedOwnedNumber(c, speedAnchors, otherAnchors))
            c,
      ];
      if (speedAnchors.isEmpty || bareNumbers.isEmpty) {
        return;
      }
      final pair = _bestUniquePair(speedAnchors, bareNumbers);
      if (pair == null) {
        return;
      }
      used
        ..add(pair.$1.index)
        ..add(pair.$2.index);
    }
  }

  /// 他フィールドより速度アンカーに近い裸数値か（距離が近ければ速度所有ではない）。
  ///
  /// Example:
  /// ```dart
  /// _isSpeedOwnedNumber(number, speedAnchors, otherAnchors);
  /// ```
  static bool _isSpeedOwnedNumber(
    _Classified number,
    List<_Classified> speedAnchors,
    List<_Classified> otherAnchors,
  ) {
    if (speedAnchors.isEmpty) {
      return false;
    }
    var bestSpeed = double.infinity;
    for (final speed in speedAnchors) {
      final d = _distance(speed.token, number.token);
      if (d < bestSpeed) {
        bestSpeed = d;
      }
    }
    if (otherAnchors.isEmpty) {
      return true;
    }
    for (final other in otherAnchors) {
      if (_distance(other.token, number.token) <= bestSpeed) {
        return false;
      }
    }
    return true;
  }

  /// コロン一意または時間ラベル近傍から運動時間を取る。
  ///
  /// Example:
  /// ```dart
  /// _resolveDuration(classified, used);
  /// ```
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

  /// 時間ラベルと近傍の時間値を一意に結ぶ。
  ///
  /// Example:
  /// ```dart
  /// _linkDurationWithAnchors(classified, used);
  /// ```
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

  /// アンカー近傍の数値を一意に結ぶ。無いときは単位付き単独値を許す。
  ///
  /// Example:
  /// ```dart
  /// _linkNumericField(
  ///   classified: classified,
  ///   used: used,
  ///   anchorKinds: {_Kind.distanceLabel},
  ///   valueKinds: {_Kind.bareNumber},
  ///   unitKind: _Kind.distanceValueWithUnit,
  /// );
  /// ```
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

  /// 同一行優先の最近傍が一意なときだけアンカーと値の組を返す。
  ///
  /// Example:
  /// ```dart
  /// _bestUniquePair(anchors, values);
  /// ```
  static (_Classified, _Classified)? _bestUniquePair(
    List<_Classified> anchors,
    List<_Classified> values,
  ) {
    final scored = <(double, bool, _Classified, _Classified)>[];
    for (final a in anchors) {
      for (final v in values) {
        scored.add((
          _distance(a.token, v.token),
          _sameRow(a.token, v.token),
          a,
          v,
        ));
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

  /// 正規化矩形中心のユークリッド距離。
  ///
  /// Example:
  /// ```dart
  /// _distance(a, b);
  /// ```
  static double _distance(MeterOcrToken a, MeterOcrToken b) {
    final dx = a.centerX - b.centerX;
    final dy = a.centerY - b.centerY;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// 縦方向のずれが行高さ閾値以内なら同一行とみなす。
  ///
  /// Example:
  /// ```dart
  /// _sameRow(a, b);
  /// ```
  static bool _sameRow(MeterOcrToken a, MeterOcrToken b) {
    final threshold = math.max(0.06, math.max(a.height, b.height));
    return (a.centerY - b.centerY).abs() <= threshold;
  }

  /// 1 トークンをラベル／単位／数値／時間／無視へ分類する。
  ///
  /// Example:
  /// ```dart
  /// _classifyAt(0, token);
  /// ```
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
    // `|` など桁化け文字は通常解析で記号ノイズとして捨てられる前に補正する。
    final hinted = _hintOcrDigits(t);
    if (hinted != t) {
      final hintedDuration = _parseDurationToken(hinted);
      if (hintedDuration != null) {
        return _Classified(
          index: index,
          token: token,
          kind: _Kind.durationValue,
          duration: hintedDuration,
        );
      }
      final hintedNumber = _parseNumberWithOptionalUnit(hinted);
      if (hintedNumber != null) {
        return _classifiedNumber(
          index: index,
          token: token,
          embedded: hintedNumber,
        );
      }
    }
    final duration = _parseDurationToken(t);
    if (duration != null) {
      return _Classified(
        index: index,
        token: token,
        kind: _Kind.durationValue,
        duration: duration,
      );
    }
    final embedded = _parseNumberWithOptionalUnit(t);
    if (embedded != null) {
      return _classifiedNumber(index: index, token: token, embedded: embedded);
    }
    return _Classified(index: index, token: token, kind: _Kind.other);
  }

  /// 数値パース結果を速度／距離／カロリー／裸数値へ振り分ける。
  ///
  /// Example:
  /// ```dart
  /// _classifiedNumber(index: 0, token: token, embedded: (12.3, 'km'));
  /// ```
  static _Classified _classifiedNumber({
    required int index,
    required MeterOcrToken token,
    required (double, String?) embedded,
  }) {
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

  /// コロン／ドット／日本語時分秒などから運動時間を取る。
  ///
  /// Example:
  /// ```dart
  /// _parseDurationToken('0.30.00');
  /// ```
  static Duration? _parseDurationToken(String normalized) {
    final colon = MeterDurationParser.parseColonOnly(normalized);
    if (colon != null) {
      return colon;
    }
    final dotted = _durationDotsToColons(normalized);
    if (dotted != null) {
      final fromDots = MeterDurationParser.parseColonOnly(dotted);
      if (fromDots != null) {
        return fromDots;
      }
    }
    return MeterDurationParser.parse(normalized);
  }

  /// `H.MM.SS` だけをコロン形式へ写す。該当しなければ null。
  ///
  /// 小数距離（`12.3`）を `M.SS` と誤認しないよう、区切りは 2 つ必須とする。
  ///
  /// Example:
  /// ```dart
  /// _durationDotsToColons('0.30.00');
  /// ```
  static String? _durationDotsToColons(String normalized) {
    if (!RegExp(r'^\d+[./]\d{1,2}[./]\d{1,2}$').hasMatch(normalized)) {
      return null;
    }
    return normalized.replaceAll(RegExp(r'[./]'), ':');
  }

  /// 七セグ OCR で桁に化けやすい文字を数字へ寄せる。
  ///
  /// 末尾単位と `h/m/s` 区切りは数値へ化けさせない。
  ///
  /// Example:
  /// ```dart
  /// _hintOcrDigits('l2.o');
  /// ```
  static String _hintOcrDigits(String normalized) {
    final unit = RegExp(r'(km/h|kmh|km|kcal|cal)$').firstMatch(normalized);
    if (unit != null) {
      final head = normalized.substring(0, unit.start);
      return '${_hintOcrDigitsRaw(head)}${unit.group(0)!}';
    }
    final hms = RegExp(r'^(.*)(h)(.*)(m)(.*)(s)$').firstMatch(normalized);
    if (hms != null) {
      return '${_hintOcrDigitsRaw(hms.group(1)!)}h'
          '${_hintOcrDigitsRaw(hms.group(3)!)}m'
          '${_hintOcrDigitsRaw(hms.group(5)!)}s';
    }
    return _hintOcrDigitsRaw(normalized);
  }

  /// 単位全体を桁ヒントで置換する。
  ///
  /// Example:
  /// ```dart
  /// _hintOcrDigitsRaw('l2.o');
  /// ```
  static String _hintOcrDigitsRaw(String normalized) {
    final buffer = StringBuffer();
    for (final unit in normalized.runes) {
      switch (unit) {
        case 0x6f: // o
        case 0x3bf: // Greek omicron
          buffer.write('0');
        case 0x6c: // l
        case 0x69: // i
        case 0x7c: // |
          buffer.write('1');
        case 0x7a: // z
          buffer.write('2');
        case 0x73: // s
          buffer.write('5');
        case 0x62: // b
          buffer.write('6');
        case 0x67: // g
        case 0x71: // q
          buffer.write('9');
        default:
          buffer.writeCharCode(unit);
      }
    }
    return buffer.toString();
  }

  /// 全角桁・全角句読点を半角にし、単位記号を ASCII へ寄せ、空白を潰す。
  ///
  /// Example:
  /// ```dart
  /// _normalize('１２．３');
  /// ```
  static String _normalize(String raw) {
    final buffer = StringBuffer();
    for (final unit in raw.runes) {
      if (unit >= 0xff10 && unit <= 0xff19) {
        buffer.writeCharCode(0x30 + (unit - 0xff10));
        continue;
      }
      if (unit == 0xff1a) {
        buffer.write(':');
        continue;
      }
      if (unit == 0xff0e || unit == 0x3002) {
        // 全角ピリオド・句点
        buffer.write('.');
        continue;
      }
      if (unit == 0x339e) {
        // ㎞
        buffer.write('km');
        continue;
      }
      buffer.writeCharCode(unit);
    }
    var text = buffer.toString().toLowerCase().trim().replaceAll(
      RegExp(r'\s+'),
      '',
    );
    // 小数のカンマ（12,3）を点へ。桁区切りの複数カンマは触らない。
    if (RegExp(r'^\d+,\d+$').hasMatch(text)) {
      text = text.replaceFirst(',', '.');
    }
    return text;
  }

  /// 正規化済み文字列から数値と任意単位を取る。
  ///
  /// 前後の記号ノイズは許し、途中に別の桁列があるときは採用しない。
  ///
  /// Example:
  /// ```dart
  /// _parseNumberWithOptionalUnit('12.3km');
  /// ```
  static (double, String?)? _parseNumberWithOptionalUnit(String normalized) {
    // 前後は記号ノイズのみ許可（英字・かな漢字は数値トークンとみなさない）。
    // 先頭の `-` は数値キャプチャ側に残し、負数チェックで落とす。
    final match = RegExp(
      r'^[^A-Za-z0-9\u3040-\u30ff\u3400-\u9fff\-]*'
      r'(-?\d+(?:\.\d+)?)'
      r'(km/h|kmh|km|kcal|cal)?'
      r'[^A-Za-z0-9\u3040-\u30ff\u3400-\u9fff]*$',
      unicode: true,
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

/// 空間推論内部のトークン種別。
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

/// 分類済みトークンと任意の数値／時間。
final class _Classified {
  /// [index] と [token] に [kind] を付ける。
  ///
  /// Example:
  /// ```dart
  /// _Classified(index: 0, token: token, kind: _Kind.other);
  /// ```
  const _Classified({
    required this.index,
    required this.token,
    required this.kind,
    this.number,
    this.duration,
  });

  /// 元リスト上の位置。
  final int index;

  /// 元トークン。
  final MeterOcrToken token;

  /// 分類結果。
  final _Kind kind;

  /// 数値フィールド用の値。
  final double? number;

  /// 時間フィールド用の値。
  final Duration? duration;
}
