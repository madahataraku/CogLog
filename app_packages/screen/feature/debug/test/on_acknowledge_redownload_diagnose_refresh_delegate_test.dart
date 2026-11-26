import 'package:infra_meter_vl_testing/infra_meter_vl_testing.dart';
import 'package:screen_feature_debug/src/viewmodel/delegate/on_acknowledge_redownload_diagnose_refresh_delegate.dart';
import 'package:test/test.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

import 'fake_redownload_meter_vl_model_usecase.dart';

void main() {
  test('execute が acknowledgeDiagnoseRefresh を呼ぶ', () async {
    final session = MeterVlRedownloadSession(meterVl: FakeMeterVlVision());
    await session.start(usecase: FakeRedownloadMeterVlModelUsecase());
    expect(session.state.state.diagnoseRefreshPending, isTrue);

    await OnAcknowledgeRedownloadDiagnoseRefreshDelegate(session: session)
        .execute();

    expect(session.state.state.diagnoseRefreshPending, isFalse);
    await session.close();
  });
}
