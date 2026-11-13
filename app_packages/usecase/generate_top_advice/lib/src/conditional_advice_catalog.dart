import 'advice_template.dart';
import 'conditional_advice_kind.dart';

/// 条件付きアドバイス定型の集合。各 [ConditionalAdviceKind] に 3 件程度を載せる。
///
/// Example:
/// ```dart
/// ConditionalAdviceCatalog(
///   over300: const [
///     AdviceTemplate(text: 'すごい', tone: AdviceTone.realized),
///   ],
/// );
/// ```
final class ConditionalAdviceCatalog {
  /// [templatesByKind] か種別ごとのリストのどちらかで定型を渡す。
  ///
  /// 同じ kind を Map と個別引数の両方に書くと assert に失敗する。
  ///
  /// Example:
  /// ```dart
  /// ConditionalAdviceCatalog.fromMap({
  ///   ConditionalAdviceKind.welcomeBack: const [
  ///     AdviceTemplate(text: 'おかえり', tone: AdviceTone.fun),
  ///   ],
  /// });
  /// ```
  ConditionalAdviceCatalog({
    Map<ConditionalAdviceKind, List<AdviceTemplate>>? templatesByKind,
    List<AdviceTemplate>? over300,
    List<AdviceTemplate>? over200,
    List<AdviceTemplate>? streakGoals,
    List<AdviceTemplate>? allPerfect,
    List<AdviceTemplate>? twoAchieved,
    List<AdviceTemplate>? oneAchieved,
    List<AdviceTemplate>? nearMissLow,
    List<AdviceTemplate>? welcomeBack,
    List<AdviceTemplate>? noPositiveGoal,
  }) : _templates = _merge(
         templatesByKind: templatesByKind,
         over300: over300,
         over200: over200,
         streakGoals: streakGoals,
         allPerfect: allPerfect,
         twoAchieved: twoAchieved,
         oneAchieved: oneAchieved,
         nearMissLow: nearMissLow,
         welcomeBack: welcomeBack,
         noPositiveGoal: noPositiveGoal,
       );

  /// 種別→定型リストの Map だけから組み立てる。
  ///
  /// Example:
  /// ```dart
  /// ConditionalAdviceCatalog.fromMap({
  ///   ConditionalAdviceKind.noPositiveGoal: const [
  ///     AdviceTemplate(text: '目標を', tone: AdviceTone.realized),
  ///   ],
  /// });
  /// ```
  ConditionalAdviceCatalog.fromMap(
    Map<ConditionalAdviceKind, List<AdviceTemplate>> templates,
  ) : _templates = Map.unmodifiable(templates);

  final Map<ConditionalAdviceKind, List<AdviceTemplate>> _templates;

  /// [kind] に対応する定型一覧。未登録の kind は空リスト。
  ///
  /// Example:
  /// ```dart
  /// catalog.templatesFor(ConditionalAdviceKind.over200);
  /// ```
  List<AdviceTemplate> templatesFor(ConditionalAdviceKind kind) {
    return _templates[kind] ?? const [];
  }

  static Map<ConditionalAdviceKind, List<AdviceTemplate>> _merge({
    Map<ConditionalAdviceKind, List<AdviceTemplate>>? templatesByKind,
    List<AdviceTemplate>? over300,
    List<AdviceTemplate>? over200,
    List<AdviceTemplate>? streakGoals,
    List<AdviceTemplate>? allPerfect,
    List<AdviceTemplate>? twoAchieved,
    List<AdviceTemplate>? oneAchieved,
    List<AdviceTemplate>? nearMissLow,
    List<AdviceTemplate>? welcomeBack,
    List<AdviceTemplate>? noPositiveGoal,
  }) {
    final merged = <ConditionalAdviceKind, List<AdviceTemplate>>{};
    if (templatesByKind != null) {
      merged.addAll(templatesByKind);
    }
    void put(ConditionalAdviceKind kind, List<AdviceTemplate>? templates) {
      if (templates == null) {
        return;
      }
      assert(
        !merged.containsKey(kind),
        'ConditionalAdviceCatalog で $kind が重複している',
      );
      merged[kind] = templates;
    }

    put(ConditionalAdviceKind.over300, over300);
    put(ConditionalAdviceKind.over200, over200);
    put(ConditionalAdviceKind.streakGoals, streakGoals);
    put(ConditionalAdviceKind.allPerfect, allPerfect);
    put(ConditionalAdviceKind.twoAchieved, twoAchieved);
    put(ConditionalAdviceKind.oneAchieved, oneAchieved);
    put(ConditionalAdviceKind.nearMissLow, nearMissLow);
    put(ConditionalAdviceKind.welcomeBack, welcomeBack);
    put(ConditionalAdviceKind.noPositiveGoal, noPositiveGoal);
    return Map.unmodifiable(merged);
  }
}
