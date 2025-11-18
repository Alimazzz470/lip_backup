import '../../../../core/dto/query_params.dart';
import '../../../../core/entities/advance.dart';
import '../../../../core/entities/bonus.dart';
import '../../../../core/entities/deduction.dart';
import '../../../../core/entities/penalty.dart';
import '../../../../core/entities/salary_type.dart';
import '../../../../core/entities/user_details.dart';
import '../../../../network/clients/cancel_token.dart';
import '../../../../network/models/input/advance_input.dart';
import '../../../../network/models/input/user_details_input.dart';
import '../../../../shared/pagination/model.dart';
import '../../../../shared/utils/result.dart';

abstract class ProfileRepository {
  const ProfileRepository();

  FutureResult<Advance> requestAdvance(
    AdvanceInput input, [
    CancellationToken? cancelToken,
  ]);

  FutureResult<PaginatedResponse<Advance>> getAdvances(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]);

  FutureResult<PaginatedResponse<Deduction>> getDeductions(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]);

  FutureResult<PaginatedResponse<Bonus>> getBonuses(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]);

  FutureResult<PaginatedResponse<Penalty>> getPenalties(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]);

  FutureResult<List<SalaryType>> getSalaryTypes(CancellationToken? cancelToken);

  FutureResult<String> getPayslip(
    QueryParams? params, [
    CancellationToken? cancelToken,
  ]);

  FutureResult<UserDetails> getUserDetails(CancellationToken? cancelToken);

  FutureResult<String?> updateUserDetails(
    UserDetailsInput input, [
    CancellationToken? cancelToken,
  ]);
}
