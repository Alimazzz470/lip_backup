import '../../../core/entities/user.dart';
import '../../../network/clients/cancel_token.dart';
import '../../../shared/utils/result.dart';

abstract class AuthenticationRepository {
  const AuthenticationRepository();

  FutureResult<User> signIn(
    String email,
    String password,
    String fcmToken, [
    CancellationToken? cancelToken,
  ]);

  FutureResult<User> me([CancellationToken? cancelToken]);

  Future<void> logout(CancellationToken? cancellationToken);

  Future<void> updateFcmToken(
    String fcmToken, [
    CancellationToken? cancelToken,
  ]);
}
