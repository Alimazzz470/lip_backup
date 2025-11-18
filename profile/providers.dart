import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taxiapp_mobile/features/profile/repositories/advances/advances_repository.dart';
import 'package:taxiapp_mobile/features/profile/repositories/advances/advances_repository_impl.dart';
import 'package:taxiapp_mobile/features/profile/repositories/bonuses/bonus_repository.dart';
import 'package:taxiapp_mobile/features/profile/repositories/bonuses/bonus_repository_impl.dart';
import 'package:taxiapp_mobile/features/profile/repositories/deductions/deduction_repository.dart';
import 'package:taxiapp_mobile/features/profile/repositories/deductions/deduction_repository_impl.dart';
import 'package:taxiapp_mobile/features/profile/repositories/penalties/penalty_repository.dart';
import 'package:taxiapp_mobile/features/profile/repositories/penalties/penalty_repository_impl.dart';

import '../../network/data_sources/profile_data_source.dart';
import '../../network/data_sources/vehicle_data_source.dart';
import '../../network/network.dart';
import 'repositories/inspection/inspection_repository.dart';
import 'repositories/inspection/inspection_repository_impl.dart';
import 'repositories/profile/profile_repository.dart';
import 'repositories/profile/profile_repository_impl.dart';
import 'repositories/request_vehicle/request_vehicle_repository.dart';
import 'repositories/request_vehicle/request_vehicle_repository_impl.dart';

final vehicleDataSourceProvider = Provider.autoDispose(
  (ref) => VehicleDataSource(ref.watch(apiClient)),
);

final requestVehicleRepositoryProvider =
    Provider.autoDispose<RequestVehicleRepository>(
  (ref) => RequestVehicleRepoImpl(
    dataSource: ref.watch(vehicleDataSourceProvider),
  ),
);

final inspectionRepositoryProvider = Provider.autoDispose<InspectionRepository>(
  (ref) => InspectionRepoImpl(
    dataSource: ref.watch(vehicleDataSourceProvider),
  ),
);

final profileDataSourceProvider = Provider.autoDispose(
  (ref) => ProfileDataSource(ref.watch(apiClient)),
);

final profileRepositoryProvider = Provider.autoDispose<ProfileRepository>(
  (ref) => ProfileRepoImpl(
    dataSource: ref.watch(profileDataSourceProvider),
  ),
);

final advanceRepositoryProvider = Provider.autoDispose<AdvanceRepository>(
  (ref) => AdvanceRepositoryImpl(
    dataSource: ref.watch(profileDataSourceProvider),
  ),
);

final bonusRepositoryProvider = Provider.autoDispose<BonusRepository>(
  (ref) => BonusRepositoryImpl(
    dataSource: ref.watch(profileDataSourceProvider),
  ),
);

final deductionRepositoryProvider = Provider.autoDispose<DeductionRepository>(
  (ref) => DeductionRepositoryImpl(
    dataSource: ref.watch(profileDataSourceProvider),
  ),
);

final penaltyRepositoryProvider = Provider.autoDispose<PenaltyRepository>(
  (ref) => PenaltyRepositoryImpl(
    dataSource: ref.watch(profileDataSourceProvider),
  ),
);
