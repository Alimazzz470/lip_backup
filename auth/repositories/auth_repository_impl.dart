import '../../../core/entities/user.dart';
import '../../../core/exceptions/exceptions.dart';
import '../../../network/clients/cancel_token.dart';
import '../../../network/data_sources/authentication_data_source.dart';
import '../../../network/data_sources/token_data_source.dart';
import '../../../shared/utils/result.dart';
import 'auth_repository.dart';

class AuthenticationRepoImpl extends AuthenticationRepository {
  final AuthenticationDataSource _dataSource;
  final TokenDataSource _tokenDataSource;

  const AuthenticationRepoImpl({
    required AuthenticationDataSource dataSource,
    required TokenDataSource tokenDataSource,
  })  : _dataSource = dataSource,
        _tokenDataSource = tokenDataSource;

  @override
  FutureResult<User> signIn(
    String email,
    String password,
    String fcmToken, [
    CancellationToken? cancelToken,
  ]) async {
    try {
      var res =
          await _dataSource.signIn(email, password, fcmToken, cancelToken);
      await _tokenDataSource.save(res.token);
      return Success(res.user);
    } on RequestCanceledException {
      return const Canceled();
    } catch (e, stackTrace) {
      if (e is CodedException) {
        return Failure(e, stackTrace);
      }
      return Failure(UnknownException(e.toString()), stackTrace);
    }
  }

  @override
  Future<void> logout(CancellationToken? cancellationToken) async {
    await _dataSource.signOut(cancellationToken);
    await _tokenDataSource.clear();
  }

  @override
  FutureResult<User> me([CancellationToken? cancelToken]) async {
    try {
      var res = await _dataSource.me(cancelToken);
      return Success(res);
    } on RequestCanceledException {
      return const Canceled();
    } catch (e, s) {
      if (e is CodedException) {
        return Failure(e, s);
      }
      return Failure(UnknownException(e.toString()), s);
    }
  }

  @override
  FutureResult<void> updateFcmToken(String fcmToken,
      [CancellationToken? cancelToken]) async {
    try {
      await _dataSource.updateFcmToken(fcmToken, cancelToken);
      return Success(null);
    } on RequestCanceledException {
      return const Canceled();
    } catch (e, s) {
      if (e is CodedException) {
        return Failure(e, s);
      }
      return Failure(UnknownException(e.toString()), s);
    }
  }
}
