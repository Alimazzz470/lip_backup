import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taxiapp_mobile/features/profile/providers/profile_providers.dart';

import '../../../network/clients/cancel_token.dart';
import '../../../network/models/input/advance_input.dart';
import '../../../shared/providers/common_providers.dart';
import '../../../shared/utils/result.dart';
import '../../../shared/utils/typedef.dart';
import '../providers.dart';
import '../repositories/profile/profile_repository.dart';

final amountProvider =
    NotifierProvider.autoDispose<AmountNotifier, String?>(AmountNotifier.new);

class AmountNotifier extends AutoDisposeNotifier<String?> {
  @override
  String? build() {
    return null;
  }

  void call(String? value) {
    state = value;
  }
}

final reasonProvider =
    NotifierProvider.autoDispose<ReasonNotifier, String?>(ReasonNotifier.new);

class ReasonNotifier extends AutoDisposeNotifier<String?> {
  @override
  String? build() {
    return null;
  }

  void call(String? value) {
    state = value;
  }
}

final payableTimeProvider =
    NotifierProvider.autoDispose<PayableTimeNotifier, int?>(
        PayableTimeNotifier.new);

class PayableTimeNotifier extends AutoDisposeNotifier<int?> {
  @override
  int? build() {
    return null;
  }

  void call(int? value) {
    state = value;
  }
}

final requestAdvanceProvider =
    NotifierProvider.autoDispose<RequestAdvanceNotifier, bool>(
        RequestAdvanceNotifier.new);

class RequestAdvanceNotifier extends AutoDisposeNotifier<bool> {
  late final ProfileRepository _profileRepository;
  late final AppMessage _appMessage;

  CancellationToken? _cancelToken;

  @override
  bool build() {
    ref.onRemoveListener(() {
      _cancelToken?.cancel();
    });

    _profileRepository = ref.read(profileRepositoryProvider);
    _appMessage = ref.read(appMessageProvider.notifier);

    return false;
  }

  void requestAdvance({
    required String amount,
    required String description,
    required String installmentPeriod,
    required OnSuccessVoidCallback onSuccess,
  }) async {
    final params = AdvanceInput(
      amount: double.parse(amount),
      description: description,
      installmentPeriod: int.parse(installmentPeriod),
    );

    state = true;
    _cancelToken = CancellationToken();
    final res = await _profileRepository.requestAdvance(params);
    _cancelToken = null;
    state = false;

    switch (res) {
      case Success _:
        onSuccess();
        ref.invalidate(salaryTypesProvider);
      case Failure e:
        _appMessage.addException(exception: e.exception);
      case Canceled _:
        break;
    }
  }
}
