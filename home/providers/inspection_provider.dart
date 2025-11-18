import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/entities/inspection.dart';
import '../../../shared/utils/result.dart';
import '../providers.dart';

final hasInspectionProvider = AsyncNotifierProvider.autoDispose<HasInspectionNotifier, Inspection?>(
    HasInspectionNotifier.new);

class HasInspectionNotifier extends AutoDisposeAsyncNotifier<Inspection?> {
  @override
  FutureOr<Inspection?> build() {
    return check();
  }

  Future<Inspection?> check() async {
    final timeTrackingRepository = ref.read(timeTrackingRepositoryProvider);

    final result = await timeTrackingRepository.inspectionAvailability();

    switch (result) {
      case Success(value: final inspection):
        state = AsyncData(inspection);
        return inspection;
      case Failure _:
        state = const AsyncData(null);
        return null;
      case Canceled _:
        state = const AsyncData(null);
        return null;
    }
  }
}
