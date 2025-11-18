import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taxiapp_mobile/features/profile/providers/profile_providers.dart';

import '../../../core/entities/time_tracking_status.dart';
import '../../../core/exceptions/signature_upload_exception.dart';
import '../../../core/services/image_helpers.dart';
import '../../../shared/providers/common_providers.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/utils/result.dart';
import '../../../shared/utils/typedef.dart';
import '../providers.dart';
import 'time_logs_providers.dart';
import 'timer_provider.dart';

final statusProvider = StateProvider.autoDispose<TimeTrackingStatus>((ref) {
  return const TimeTrackingStatus.empty();
});

final timeTrackingNotifierProvider =
    NotifierProvider.autoDispose<TimeTrackingNotifier, bool>(
        TimeTrackingNotifier.new);

class TimeTrackingNotifier extends AutoDisposeNotifier<bool> {
  @override
  build() {
    return false;
  }

  Future<void> init() async {
    final timeTrackingRepository = ref.read(timeTrackingRepositoryProvider);
    final appMessage = ref.read(appMessageProvider.notifier);

    final result = await timeTrackingRepository.getStatus();

    switch (result) {
      case Success(value: final status):
        ref.read(statusProvider.notifier).state = status;
        ref.read(timeTrackingIdProvider.notifier).set(status.timeTrackingId);
      case Failure(exception: final exception):
        ref.read(statusProvider.notifier).state =
            const TimeTrackingStatus.empty();
        appMessage.addException(exception: exception);
      case Canceled():
        ref.read(statusProvider.notifier).state =
            const TimeTrackingStatus.empty();
    }
  }

  void startTracking({
    required String startKm,
    required String startTime,
    required OnSuccessVoidCallback onSuccess,
  }) async {
    final timeTrackingRepository = ref.watch(timeTrackingRepositoryProvider);
    final appMessage = ref.watch(appMessageProvider.notifier);

    final result =
        await timeTrackingRepository.startTracking(startKm, startTime);

    switch (result) {
      case Success(value: final id):
        await init();
        ref.read(timerNotifierProvider.notifier).start();
        ref.read(timeTrackingIdProvider.notifier).set(id);
        ref.invalidate(assignedVehicleProvider);
        ref.invalidate(todayLogProvider);
        onSuccess();
        break;
      case Failure(exception: final exception):
        appMessage.addException(exception: exception);
        break;
      case Canceled():
        break;
    }
  }

  void stopTracking({
    required String timeTrackingId,
    required String endKm,
    required String endTime,
    required Uint8List imageBytes,
    required OnSuccessVoidCallback onSuccess,
  }) async {
    final timeTrackingRepository = ref.watch(timeTrackingRepositoryProvider);
    final appMessage = ref.watch(appMessageProvider.notifier);

    final confirmationId = await uploadSignature(imageBytes);

    if (confirmationId == null) {
      appMessage.addException(
        exception: const SignatureUploadException(),
      );
      return;
    }

    final isUploaded = await timeTrackingRepository.timeTrackingSignature(
      timeTrackingId: timeTrackingId,
      confirmationId: confirmationId,
    );

    isUploaded.when(
      success: (success) async {
        final result =
            await timeTrackingRepository.stopTracking(endKm, endTime);

        switch (result) {
          case Success(value: final _):
            await init();
            ref.read(timerNotifierProvider.notifier).stop();
            ref.invalidate(todayLogProvider);
            ref.invalidate(assignedVehicleProvider);
            onSuccess();
            break;
          case Failure(exception: final exception):
            appMessage.addException(exception: exception);
            break;
          case Canceled():
            break;
        }
      },
      failure: (error, stackTrace) {
        appMessage.addException(exception: error);
      },
    );
  }

  void startBreak({
    required String startTime,
    required OnSuccessVoidCallback onSuccess,
  }) async {
    final timeTrackingRepository = ref.watch(timeTrackingRepositoryProvider);
    final appMessage = ref.watch(appMessageProvider.notifier);

    final result = await timeTrackingRepository.startBreak(startTime);

    switch (result) {
      case Success(value: final _):
        await init();
        ref.read(timerNotifierProvider.notifier).pause();
        ref.invalidate(todayLogProvider);
        onSuccess();
        break;
      case Failure(exception: final exception):
        appMessage.addException(exception: exception);
        break;
      case Canceled():
        break;
    }
  }

  void stopBreak({
    required String endTime,
    required OnSuccessVoidCallback onSuccess,
  }) async {
    final timeTrackingRepository = ref.watch(timeTrackingRepositoryProvider);
    final appMessage = ref.watch(appMessageProvider.notifier);

    final result = await timeTrackingRepository.stopBreak(endTime);

    switch (result) {
      case Success(value: final _):
        await init();
        ref.read(timerNotifierProvider.notifier).start();
        ref.invalidate(todayLogProvider);
        onSuccess();
        break;
      case Failure(exception: final exception):
        appMessage.addException(exception: exception);
        break;
      case Canceled():
        break;
    }
  }

  Future<String?> uploadSignature(Uint8List imageBytes) async {
    bool uploadSuccess = true;

    final _sharedRepository = ref.watch(sharedRepositoryProvider);
    final _appMessage = ref.watch(appMessageProvider.notifier);

    final links = await _sharedRepository.getUploadLinks(
      1,
      UploadImageType.SIGNATURE,
    );

    switch (links) {
      case Success(value: final data):
        try {
          await uploadInBytes(
            uploadUrl: data.uri[0],
            imageBytes: imageBytes,
          );
        } catch (e) {
          uploadSuccess = false;
        }

        if (uploadSuccess) {
          return data.confirmationId;
        }

        return null;
      case Failure e:
        _appMessage.addException(exception: e.exception);
        return null;
      case Canceled _:
        return null;
    }
  }
}

final timeTrackingIdProvider = NotifierProvider<TimeTrackingIdNotifier, String>(
    TimeTrackingIdNotifier.new);

class TimeTrackingIdNotifier extends Notifier<String> {
  @override
  build() {
    return '';
  }

  void set(String id) {
    state = id;
  }
}
