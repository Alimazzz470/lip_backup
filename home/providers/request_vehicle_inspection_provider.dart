import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taxiapp_mobile/features/home/providers/inspection_provider.dart';
import 'package:taxiapp_mobile/features/profile/providers/profile_providers.dart';

import '../../../core/services/image_helpers.dart';
import '../../../shared/providers/common_providers.dart';
import '../../../shared/repositories/shared_repository.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/utils/result.dart';
import '../../../shared/utils/typedef.dart';
import '../../profile/profile_extensions.dart';
import '../../profile/providers.dart';
import '../../profile/providers/return_vehicle_providers.dart';
import '../../profile/repositories/inspection/inspection_repository.dart';

final requestVehicleInspectionProvider =
    NotifierProvider.autoDispose<MonthlyInspectionNotifier, bool>(
        MonthlyInspectionNotifier.new);

class MonthlyInspectionNotifier extends AutoDisposeNotifier<bool> {
  late final SharedRepository _sharedRepository;
  late final InspectionRepository _inspectionRepository;
  late final AppMessage _appMessage;

  @override
  bool build() {
    _sharedRepository = ref.read(sharedRepositoryProvider);
    _inspectionRepository = ref.read(inspectionRepositoryProvider);
    _appMessage = ref.read(appMessageProvider.notifier);

    return false;
  }

  void submit({
    required String inspectionId,
    required String vehicleTypeId,
    required Uint8List signatureBytes,
    required OnSuccessVoidCallback onSuccess,
    required void Function() onError,
  }) async {
    state = true;

    final totalKms = ref.read(totalTraveledProvider);

    final ids = await Future.wait([
      _uploadImages(),
      _uploadSignature(signatureBytes),
    ]);
    final String? inspectionConfirmationId = ids[0];
    final String? signatureConfirmationId = ids[1];

    if (inspectionConfirmationId == null || signatureConfirmationId == null) {
      state = false;
      onError();
      return;
    }

    final result = await _inspectionRepository.monthlyInspection(
      inspectionId: inspectionId,
      kms: int.parse(totalKms!),
      vehicleTypeId: vehicleTypeId,
      confirmationId: inspectionConfirmationId,
      signatureId: signatureConfirmationId,
    );

    state = false;

    result.when(
      success: (_) async {
        onSuccess();
        ref.invalidate(hasInspectionProvider);
        ref.invalidate(assignedVehicleProvider);

        // ref.invalidate(statusProvider);
      },
      failure: (error, stackTrace) {
        _appMessage.addException(
          exception: error,
          retry: () {
            submit(
              inspectionId: inspectionId,
              vehicleTypeId: vehicleTypeId,
              signatureBytes: signatureBytes,
              onSuccess: onSuccess,
              onError: onError,
            );
          },
        );
      },
    );
  }

  Future<String?> _uploadImages() async {
    bool uploadSuccess = true;

    final links = await _sharedRepository.getUploadLinks(
      1,
      UploadImageType.CAR_INSPECTION,
    );

    switch (links) {
      case Success(value: final data):
        final inspectionImages = ref.read(setInspectionImagesProvider);

        await Future.wait(VehicleInspectionType.values.map((type) async {
          final inspectionImage =
              inspectionImages.firstWhere((image) => image.type == type);
          final uploadUrl = data.carInspection[type];
          try {
            await upload(
              uploadUrl: uploadUrl,
              imageFile: File(inspectionImage.selectedImagePath!),
            );
          } catch (e) {
            uploadSuccess = false;
          }
        }));

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

  Future<String?> _uploadSignature(Uint8List imageBytes) async {
    bool uploadSuccess = true;

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
