import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchVehicleDTO {
  final String? vehicleNumber;
  final String? vehicleTypeId;

  const SearchVehicleDTO({
    this.vehicleNumber,
    this.vehicleTypeId,
  });

  const SearchVehicleDTO.empty()
      : vehicleNumber = null,
        vehicleTypeId = null;

  SearchVehicleDTO copyWith({
    String? vehicleNumber,
    String? vehicleTypeId,
  }) {
    return SearchVehicleDTO(
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleTypeId: vehicleTypeId ?? this.vehicleTypeId,
    );
  }

  bool get isEmpty => vehicleNumber == null && vehicleTypeId == null;
}

final searchVehicleProvider = NotifierProvider.autoDispose<SearchVehicleNotifier, SearchVehicleDTO>(
    SearchVehicleNotifier.new);

class SearchVehicleNotifier extends AutoDisposeNotifier<SearchVehicleDTO> {
  @override
  SearchVehicleDTO build() {
    return const SearchVehicleDTO.empty();
  }

  void search({
    String? vehicleNumber,
    String? vehicleTypeId,
  }) {
    state = state.copyWith(
      vehicleNumber: vehicleNumber,
      vehicleTypeId: vehicleTypeId,
    );
  }

  void clear() {
    state = const SearchVehicleDTO.empty();
  }
}
