import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/image_helpers.dart';
import '../../../shared/providers/common_providers.dart';
import '../../../shared/repositories/shared_repository.dart';
import '../../../shared/utils/enums.dart';
import '../../../shared/utils/result.dart';
import '../../../shared/utils/typedef.dart';
import '../../home/providers/inspection_provider.dart';
import '../profile_extensions.dart';
import '../providers.dart';
import '../repositories/inspection/inspection_repository.dart';
import 'profile_providers.dart';

final totalTraveledProvider =
    NotifierProvider.autoDispose<TotalTravelKMNotifier, String?>(TotalTravelKMNotifier.new);

class TotalTravelKMNotifier extends AutoDisposeNotifier<String?> {
  @override
  build() {
    return null;
  }

  void setKm(String km) {
    state = km;
  }
}

final setInspectionImagesProvider =
    NotifierProvider.autoDispose<SetInspectionImagesNotifier, List<VehicleInspection>>(
        SetInspectionImagesNotifier.new);

class SetInspectionImagesNotifier extends AutoDisposeNotifier<List<VehicleInspection>> {
  @override
  List<VehicleInspection> build() {
    return vehicleSides;
  }

  void setImage(String imagePath, VehicleInspectionType type) {
    state = state.map((e) {
      if (e.type == type) {
        return e.copyWith(selectedImagePath: imagePath);
      }
      return e;
    }).toList();
  }

  void removeImage(VehicleInspectionType type) {
    state = state.map((e) {
      if (e.type == type) {
        return e.copyWith(selectedImagePath: null);
      }
      return e;
    }).toList();
  }
}

final submitInspectionProvider =
    NotifierProvider.autoDispose<SubmitInspectionNotifier, bool>(SubmitInspectionNotifier.new);

class SubmitInspectionNotifier extends AutoDisposeNotifier<bool> {
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

    final result = await _inspectionRepository.returnVehicle(
      kms: int.parse(totalKms!),
      vehicleTypeId: vehicleTypeId,
      confirmationId: inspectionConfirmationId,
      signatureId: signatureConfirmationId,
    );

    state = false;

    result.when(
      success: (_) async {
        await Future.delayed(const Duration(milliseconds: 500), () {
          ref.invalidate(assignedVehicleProvider);
          ref.invalidate(hasInspectionProvider);
          onSuccess();
        });
      },
      failure: (error, stackTrace) {
        _appMessage.addException(
          exception: error,
          retry: () {
            submit(
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
          final inspectionImage = inspectionImages.firstWhere((image) => image.type == type);
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
