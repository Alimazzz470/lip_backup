import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/exceptions/no_stored_token_exception.dart';
import '../../../network/network.dart';
import '../../../shared/providers/common_providers.dart';
import '../../../shared/utils/result.dart';
import '../../../shared/utils/typedef.dart';
import '../repositories/auth_repository.dart';
import 'providers.dart';

final authStateProvider = FutureProvider.autoDispose<bool?>((ref) async {
  try {
    // Rebuild on user changes
    var (String id, _) =
        ref.watch(loggedInUserProvider.select((v) => (v.id, v.email)));
    if (id.isNotEmpty) return true;

    // Try to fetch the token. Will throw if unavailable
    await ref.watch(tokenDataSource).get();

    // Get the current user response and update loggedInUser for redirection
    var res = await ref.watch(authenticationRepository).me();

    switch (res) {
      case Success(value: final s):
        ref.read(loggedInUserProvider.notifier).changeUser(s);
      case Failure e:
        ref
            .read(appMessageProvider.notifier)
            .addException(exception: e.exception, retry: ref.invalidateSelf);
      case Canceled _:
        return false;
    }

    return null;
  } on NoStoredTokenException {
    // Expected error..delay to show the splash screen for a little while
    return Future.delayed(const Duration(milliseconds: 500), () => false);
  } catch (_) {
    return false;
  }
});

final authStateNotifierProvider =
    StateNotifierProvider.autoDispose<AuthStateNotifier, AsyncValue<bool>>(
        (ref) {
  return AuthStateNotifier(
    authenticationRepository: ref.watch(authenticationRepository),
    onUserChange: (user) {
      ref.read(loggedInUserProvider.notifier).changeUser(user);
    },
  );
});

class AuthStateNotifier extends StateNotifier<AsyncValue<bool>> {
  final AuthenticationRepository _authenticationRepository;
  final OnUserChange onUserChange;

  AuthStateNotifier({
    required AuthenticationRepository authenticationRepository,
    required this.onUserChange,
  })  : _authenticationRepository = authenticationRepository,
        super(const AsyncData(false));

  void signIn({
    required String email,
    required String password,
    required String fcmToken,
    required OnErrorCallback onError,
  }) async {
    state = const AsyncLoading();

    final result =
        await _authenticationRepository.signIn(email, password, fcmToken);

    switch (result) {
      case Success(value: final user):
        state = const AsyncData(false);
        onUserChange(user);
      case Failure(exception: final exception):
        state = const AsyncData(false);
        onError(exception);
      case Canceled():
        break;
    }
  }
}

final fcmTokenProvider = StateProvider<String>((_) => "");
