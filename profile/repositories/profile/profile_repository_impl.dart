import '../../../../core/dto/query_params.dart';
import '../../../../core/entities/advance.dart';
import '../../../../core/entities/bonus.dart';
import '../../../../core/entities/deduction.dart';
import '../../../../core/entities/penalty.dart';
import '../../../../core/entities/salary_type.dart';
import '../../../../core/entities/user_details.dart';
import '../../../../core/exceptions/exceptions.dart';
import '../../../../network/clients/cancel_token.dart';
import '../../../../network/data_sources/profile_data_source.dart';
import '../../../../network/models/input/advance_input.dart';
import '../../../../network/models/input/user_details_input.dart';
import '../../../../shared/pagination/model.dart';
import '../../../../shared/utils/result.dart';
import 'profile_repository.dart';

class ProfileRepoImpl extends ProfileRepository {
  final ProfileDataSource _dataSource;

  const ProfileRepoImpl({
    required ProfileDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  FutureResult<Advance> requestAdvance(
    AdvanceInput input, [
    CancellationToken? cancelToken,
  ]) async {
    try {
      final result = await _dataSource.requestAdvance(input, cancelToken);

      return Success(result);
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
  FutureResult<PaginatedResponse<Advance>> getAdvances(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]) async {
    try {
      final result = await _dataSource.getAdvances(
        params: params,
        cancelToken: cancelToken,
      );

      return Success(result);
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
  FutureResult<PaginatedResponse<Deduction>> getDeductions(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]) async {
    try {
      final result = await _dataSource.getDeductions(
        params: params,
        cancelToken: cancelToken,
      );

      return Success(result);
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
  FutureResult<PaginatedResponse<Bonus>> getBonuses(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]) async {
    try {
      final result = await _dataSource.getBonus(
        params: params,
        cancelToken: cancelToken,
      );

      return Success(result);
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
  FutureResult<PaginatedResponse<Penalty>> getPenalties(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]) async {
    try {
      final result = await _dataSource.getPenalties(
        params: params,
        cancelToken: cancelToken,
      );

      return Success(result);
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
  FutureResult<List<SalaryType>> getSalaryTypes(
    CancellationToken? cancelToken,
  ) async {
    try {
      final result = await _dataSource.getSalaryTypes(cancelToken);

      return Success(result);
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
  FutureResult<String> getPayslip(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]) async {
    try {
      final result = await _dataSource.getPayslip(params, cancelToken);

      return Success(result);
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
  FutureResult<UserDetails> getUserDetails(
      CancellationToken? cancelToken) async {
    try {
      final result = await _dataSource.getUserDetails(cancelToken);

      return Success(result);
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
  FutureResult<String?> updateUserDetails(
    UserDetailsInput input, [
    CancellationToken? cancelToken,
  ]) async {
    try {
      final result = await _dataSource.updateProfile(input, cancelToken);

      return Success(result);
    } on RequestCanceledException {
      return const Canceled();
    } catch (e, stackTrace) {
      if (e is CodedException) {
        return Failure(e, stackTrace);
      }
      return Failure(UnknownException(e.toString()), stackTrace);
    }
  }
}
