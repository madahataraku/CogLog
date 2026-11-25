import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:domain_tutorial/domain_tutorial.dart';

import 'cogsav_document.dart';
import 'cogsav_exceptions.dart';
import 'cogsav_json_mapper.dart';

/// `.cogsav`（ZIP）と [CogsavDocument] の相互変換。
///
/// Example:
/// ```dart
/// final bytes = CogsavCodec.encode(
///   CogsavDocument(
///     formatVersion: CogsavCodec.formatVersion,
///     exportedAt: DateTime.utc(2026, 11, 20),
///     exerciseHistories: const [],
///     dailyGoal: DailyGoal.unset,
///     dailyGoalAutoUpdate: DailyGoalAutoUpdateSettings.defaults,
///     notificationSettings: NotificationSettings.initial,
///     achievementUnlocks: const [],
///     achievementLastViewedAt: null,
///     tutorial: TutorialProgress.initial,
///     photos: const {},
///   ),
/// );
/// CogsavCodec.decode(bytes);
/// ```
abstract final class CogsavCodec {
  /// このアプリが書く形式の版。
  static const int formatVersion = 1;

  /// ZIP 内のファイル数上限（ディレクトリ除く）。
  static const int maxArchiveEntries = 5000;

  /// 1 エントリあたりの展開後バイト上限。
  static const int maxEntryUncompressedBytes = 8 * 1024 * 1024;

  /// 全エントリの展開後バイト合計上限。
  static const int maxTotalUncompressedBytes = 64 * 1024 * 1024;

  static final RegExp _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  static final RegExp _photoPath = RegExp(
    r'^photos/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})\.jpg$',
  );

  /// [document] を ZIP バイト列にする。
  ///
  /// [CogsavDocument.tutorial] が null のときは [TutorialProgress.initial] を書く。
  ///
  /// Example:
  /// ```dart
  /// CogsavCodec.encode(
  ///   CogsavDocument(
  ///     formatVersion: CogsavCodec.formatVersion,
  ///     exportedAt: DateTime.utc(2026, 11, 20),
  ///     exerciseHistories: const [],
  ///     dailyGoal: DailyGoal.unset,
  ///     dailyGoalAutoUpdate: DailyGoalAutoUpdateSettings.defaults,
  ///     notificationSettings: NotificationSettings.initial,
  ///     achievementUnlocks: const [],
  ///     achievementLastViewedAt: null,
  ///     tutorial: TutorialProgress.initial,
  ///     photos: const {},
  ///   ),
  /// );
  /// ```
  static Uint8List encode(CogsavDocument document) {
    final manifest = <String, Object?>{
      'formatVersion': document.formatVersion,
      'exportedAt': document.exportedAt.toUtc().toIso8601String(),
    };
    final data = CogsavJsonMapper.encodeDataPayload(
      exerciseHistories: document.exerciseHistories,
      dailyGoal: document.dailyGoal,
      dailyGoalAutoUpdate: document.dailyGoalAutoUpdate,
      notificationSettings: document.notificationSettings,
      achievementUnlocks: document.achievementUnlocks,
      achievementLastViewedAt: document.achievementLastViewedAt,
      tutorial: document.tutorial ?? TutorialProgress.initial,
    );

    final archive = Archive()
      ..add(ArchiveFile.string('manifest.json', jsonEncode(manifest)))
      ..add(ArchiveFile.string('data.json', jsonEncode(data)));

    for (final entry in document.photos.entries) {
      if (!_uuid.hasMatch(entry.key)) {
        throw ArgumentError.value(entry.key, 'photos.keys', 'UUID 形式である必要がある');
      }
      archive.add(ArchiveFile.bytes('photos/${entry.key}.jpg', entry.value));
    }

    return ZipEncoder().encodeBytes(archive);
  }

  /// ZIP バイト列を [CogsavDocument] にする。
  ///
  /// 壊れている・許可外パス・重複エントリは [CogsavCorruptException]。
  /// 版が [formatVersion] 以外は [CogsavUnsupportedVersionException]。
  /// `data.json` に `tutorial` キーが無いときは [CogsavDocument.tutorial] を null にする。
  ///
  /// Example:
  /// ```dart
  /// CogsavCodec.decode(Uint8List(0)); // throws CogsavCorruptException
  /// ```
  static CogsavDocument decode(Uint8List bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } on CogsavCorruptException {
      rethrow;
    } on Object {
      throw const CogsavCorruptException('ZIP として読めない');
    }

    final seenNames = <String>{};
    ArchiveFile? manifestFile;
    ArchiveFile? dataFile;
    final photoFiles = <String, ArchiveFile>{};
    var entryCount = 0;
    var totalUncompressed = 0;

    for (final file in archive) {
      final name = file.name.replaceAll('\\', '/');
      if (file.isDirectory || name.endsWith('/')) {
        continue;
      }
      entryCount += 1;
      if (entryCount > maxArchiveEntries) {
        throw const CogsavCorruptException('ZIP エントリ数が上限を超える');
      }
      if (file.size < 0 || file.size > maxEntryUncompressedBytes) {
        throw CogsavCorruptException('エントリサイズが不正: $name');
      }
      totalUncompressed += file.size;
      if (totalUncompressed > maxTotalUncompressedBytes) {
        throw const CogsavCorruptException('展開後サイズ合計が上限を超える');
      }
      if (name.contains('..') || name.startsWith('/')) {
        throw CogsavCorruptException('許可されないパス: $name');
      }
      if (!seenNames.add(name)) {
        throw CogsavCorruptException('エントリ名が重複: $name');
      }

      if (name == 'manifest.json') {
        manifestFile = file;
        continue;
      }
      if (name == 'data.json') {
        dataFile = file;
        continue;
      }
      final photoMatch = _photoPath.firstMatch(name);
      if (photoMatch != null) {
        photoFiles[photoMatch.group(1)!] = file;
        continue;
      }
      throw CogsavCorruptException('許可されないパス: $name');
    }

    if (manifestFile == null) {
      throw const CogsavCorruptException('manifest.json が無い');
    }
    if (dataFile == null) {
      throw const CogsavCorruptException('data.json が無い');
    }

    final manifest = _decodeJsonObject(
      _readUtf8(manifestFile),
      field: 'manifest.json',
    );
    final versionRaw = manifest['formatVersion'];
    if (versionRaw is! int) {
      throw const CogsavCorruptException('formatVersion が整数でない');
    }
    final version = versionRaw;
    if (version != formatVersion) {
      throw CogsavUnsupportedVersionException(version);
    }

    final exportedAtRaw = manifest['exportedAt'];
    if (exportedAtRaw is! String) {
      throw const CogsavCorruptException('exportedAt が文字列でない');
    }
    final exportedAt = DateTime.tryParse(exportedAtRaw);
    if (exportedAt == null) {
      throw const CogsavCorruptException('exportedAt の日時が不正');
    }

    final dataRaw = _decodeJsonObject(_readUtf8(dataFile), field: 'data.json');
    final payload = CogsavJsonMapper.decodeDataPayload(dataRaw);

    final photos = <String, Uint8List>{};
    for (final entry in photoFiles.entries) {
      final content = _readBytes(entry.value);
      photos[entry.key] = content;
    }

    return CogsavDocument(
      formatVersion: version,
      exportedAt: exportedAt.toUtc(),
      exerciseHistories: payload.exerciseHistories,
      dailyGoal: payload.dailyGoal,
      dailyGoalAutoUpdate: payload.dailyGoalAutoUpdate,
      notificationSettings: payload.notificationSettings,
      achievementUnlocks: payload.achievementUnlocks,
      achievementLastViewedAt: payload.achievementLastViewedAt,
      tutorial: payload.tutorial,
      photos: photos,
    );
  }

  static Uint8List _readBytes(ArchiveFile file) {
    final List<int>? content;
    try {
      content = file.readBytes();
    } on Object {
      throw CogsavCorruptException('${file.name} を読めない');
    }
    if (content == null) {
      throw CogsavCorruptException('${file.name} を読めない');
    }
    if (content.length > maxEntryUncompressedBytes) {
      throw CogsavCorruptException('エントリサイズが不正: ${file.name}');
    }
    return Uint8List.fromList(content);
  }

  static String _readUtf8(ArchiveFile file) {
    final content = _readBytes(file);
    try {
      return utf8.decode(content);
    } on Object {
      throw CogsavCorruptException('${file.name} が UTF-8 でない');
    }
  }

  static Map<Object?, Object?> _decodeJsonObject(
    String raw, {
    required String field,
  }) {
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on Object catch (error) {
      throw CogsavCorruptException('$field が JSON でない: $error');
    }
    if (decoded is Map<Object?, Object?>) {
      return decoded;
    }
    if (decoded is Map) {
      return decoded.cast<Object?, Object?>();
    }
    throw CogsavCorruptException('$field がオブジェクトでない');
  }
}
