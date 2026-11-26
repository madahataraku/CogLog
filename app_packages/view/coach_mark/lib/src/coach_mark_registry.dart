import 'package:flutter/widgets.dart';

import 'coach_mark_target_id.dart';

/// ターゲット矩形の登録台帳（プロセス内・Provider keepAlive）。
///
/// Example:
/// ```dart
/// CoachMarkRegistry();
/// ```
final class CoachMarkRegistry {
  /// 空の台帳を作る。
  ///
  /// Example:
  /// ```dart
  /// CoachMarkRegistry();
  /// ```
  CoachMarkRegistry();

  /// id → GlobalKey。
  final Map<CoachMarkTargetId, GlobalKey> _keys = {};

  /// [id] を [key] で登録する。同一 id の再登録は上書き。
  ///
  /// Example:
  /// ```dart
  /// registry.register(CoachMarkTargetId.navHome, GlobalKey());
  /// ```
  void register(CoachMarkTargetId id, GlobalKey key) {
    _keys[id] = key;
  }

  /// [id] が [key] のときだけ外す（別キーで上書き済みなら触らない）。
  ///
  /// Example:
  /// ```dart
  /// registry.unregister(CoachMarkTargetId.navHome, key);
  /// ```
  void unregister(CoachMarkTargetId id, GlobalKey key) {
    if (_keys[id] == key) {
      _keys.remove(id);
    }
  }

  /// [id] に登録した [GlobalKey]。未登録は null。
  ///
  /// Example:
  /// ```dart
  /// registry.keyFor(CoachMarkTargetId.navHome);
  /// ```
  GlobalKey? keyFor(CoachMarkTargetId id) => _keys[id];

  /// [id] の画面座標矩形。取得失敗時は null。
  ///
  /// [overlayContext] は Overlay 側の文脈。座標はグローバル原点基準。
  ///
  /// Example:
  /// ```dart
  /// registry.rectFor(CoachMarkTargetId.navHome, context);
  /// ```
  Rect? rectFor(CoachMarkTargetId id, BuildContext overlayContext) {
    final key = _keys[id];
    if (key == null) {
      return null;
    }
    final context = key.currentContext;
    if (context == null) {
      return null;
    }
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }
    final topLeft = renderObject.localToGlobal(Offset.zero);
    return topLeft & renderObject.size;
  }
}
