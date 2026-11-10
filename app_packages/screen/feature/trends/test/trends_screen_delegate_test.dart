import 'package:flutter_test/flutter_test.dart';
import 'package:screen_feature_trends/src/viewmodel/delegate/on_select_group_delegate.dart';
import 'package:screen_feature_trends/src/viewmodel/delegate/on_select_period_delegate.dart';
import 'package:screen_feature_trends/src/viewmodel/delegate/trends_state_to_entity_delegate.dart';
import 'package:screen_feature_trends/src/viewmodel/state/trends_screen_state.dart';
import 'package:state_stream/state_stream.dart';

void main() {
  late MutableStateStream<TrendsScreenState> state;

  setUp(() {
    state = MutableStateStream(TrendsScreenState.initial);
  });

  tearDown(() async {
    await state.close();
  });

  test('初期値は過去30日・運動', () {
    expect(state.state.period, TrendsPeriod.days30);
    expect(state.state.group, TrendsMetricGroup.exercise);
    final entity = const TrendsStateToEntityDelegate().execute(state.state);
    expect(entity.period, TrendsPeriod.days30);
    expect(entity.group, TrendsMetricGroup.exercise);
  });

  test('期間を変えると period だけ変わる', () async {
    await OnSelectPeriodDelegate(state: state).execute(TrendsPeriod.days90);
    expect(state.state.period, TrendsPeriod.days90);
    expect(state.state.group, TrendsMetricGroup.exercise);
  });

  test('同じ期間では State を変えない', () async {
    await OnSelectPeriodDelegate(state: state).execute(TrendsPeriod.days90);
    await OnSelectPeriodDelegate(state: state).execute(TrendsPeriod.days90);
    expect(state.state.period, TrendsPeriod.days90);
  });

  test('グループを変えると group だけ変わる', () async {
    await OnSelectGroupDelegate(state: state).execute(TrendsMetricGroup.body);
    expect(state.state.group, TrendsMetricGroup.body);
    expect(state.state.period, TrendsPeriod.days30);
  });

  test('同じグループでは State を変えない', () async {
    await OnSelectGroupDelegate(state: state).execute(TrendsMetricGroup.body);
    await OnSelectGroupDelegate(state: state).execute(TrendsMetricGroup.body);
    expect(state.state.group, TrendsMetricGroup.body);
  });
}
