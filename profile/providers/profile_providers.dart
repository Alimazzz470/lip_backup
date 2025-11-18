import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/entities/salary_type.dart';
import '../../../core/entities/user_details.dart';
import '../../../core/entities/vehicle/vehicle.dart';
import '../../../core/services/image_helpers.dart';
import '../../../network/clients/cancel_token.dart';
import '../../../network/models/input/user_details_input.dart';
import '../../../shared/providers/common_providers.dart';
import '../../../shared/utils/result.dart';
import '../../../shared/utils/typedef.dart';
import '../../auth/providers/providers.dart';
import '../providers.dart';

final assignedVehicleProvider =
    FutureProvider.autoDispose<Vehicle?>((ref) async {
  final requestVehicle = ref.watch(requestVehicleRepositoryProvider);

  final result = await requestVehicle.vehicleAssigned();

  switch (result) {
    case Success(value: final vehicle):
      return vehicle;
    case Failure(exception: final exception):
      debugPrint(exception.message.toString());
      return null;
    case Canceled():
      return null;
  }
});

final salaryTypesProvider =
    AsyncNotifierProvider.autoDispose<SalaryTypeNotifier, List<SalaryType>>(
        SalaryTypeNotifier.new);

class SalaryTypeNotifier extends AutoDisposeAsyncNotifier<List<SalaryType>> {
  CancellationToken? _cancelToken;

  @override
  FutureOr<List<SalaryType>> build() {
    return _load();
  }

  Future<List<SalaryType>> _load() async {
    final profileRepository = ref.read(profileRepositoryProvider);

    _cancelToken = CancellationToken();
    var res = await profileRepository.getSalaryTypes(
      _cancelToken,
    );
    _cancelToken = null;

    switch (res) {
      case Success(value: final salaryTypes):
        return salaryTypes;
      case Failure(exception: final exception):
        debugPrint(exception.message.toString());
        return [];
      case Canceled():
        return [];
    }
  }
}

final userDetailsProvider =
    AsyncNotifierProvider.autoDispose<UserDetailsNotifier, UserDetails>(
        UserDetailsNotifier.new);

class UserDetailsNotifier extends AutoDisposeAsyncNotifier<UserDetails> {
  CancellationToken? _cancelToken;

  @override
  FutureOr<UserDetails> build() {
    return _load();
  }

  Future<UserDetails> _load() async {
    final profileRepository = ref.read(profileRepositoryProvider);
    final appMessage = ref.read(appMessageProvider.notifier);

    _cancelToken = CancellationToken();
    var res = await profileRepository.getUserDetails(_cancelToken);
    _cancelToken = null;

    switch (res) {
      case Success(value: final userDetails):
        return userDetails;
      case Failure(exception: final exception):
        appMessage.addException(exception: exception);
        return UserDetails.empty();
      case Canceled():
        return UserDetails.empty();
    }
  }
}

final updateProfileProvider =
    NotifierProvider.autoDispose<UpdateProfileNotifier, bool>(
        UpdateProfileNotifier.new);

class UpdateProfileNotifier extends AutoDisposeNotifier<bool> {
  CancellationToken? _cancelToken;

  @override
  bool build() {
    return false;
  }

  Future<void> update({
    required UserDetailsInput userDetailsInput,
    required OnSuccessVoidCallback onSuccess,
  }) async {
    state = true;

    final profileRepository = ref.read(profileRepositoryProvider);
    final appMessage = ref.read(appMessageProvider.notifier);

    final avatar = ref.read(avatarProvider);

    _cancelToken = CancellationToken();
    var res = await profileRepository.updateUserDetails(
        userDetailsInput, _cancelToken);
    _cancelToken = null;

    res.when(success: (url) async {
      if (avatar != null && url != null) {
        final bytes = avatar.readAsBytesSync();
        await uploadInBytes(
          uploadUrl: url,
          imageBytes: bytes,
          uploadProgressFn: (progress) {
            debugPrint('Upload progress: $progress');
          },
        );
      }

      state = false;
      ref.invalidate(loggedInUserProvider);
      onSuccess();
    }, failure: (failure, stackTrace) {
      state = false;
      appMessage.addException(exception: failure);
    });
  }
}

final logoutProvider =
    NotifierProvider.autoDispose<LogoutNotifier, bool>(LogoutNotifier.new);

class LogoutNotifier extends AutoDisposeNotifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> logout() async {
    final authRepo = ref.read(authenticationRepository);
    await authRepo
        .logout(
          CancellationToken(),
        )
        .then((value) => ref.invalidate(loggedInUserProvider));
  }
}

final avatarProvider =
    NotifierProvider.autoDispose<AvatarNotifier, File?>(AvatarNotifier.new);

class AvatarNotifier extends AutoDisposeNotifier<File?> {
  @override
  File? build() {
    return null;
  }

  void update(File? avatar) {
    state = avatar;
  }
}
