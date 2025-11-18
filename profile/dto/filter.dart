import 'package:equatable/equatable.dart';

class FilterDto extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterDto({this.startDate, this.endDate});

  factory FilterDto.empty() {
    return const FilterDto(
      startDate: null,
      endDate: null,
    );
  }

  FilterDto copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return FilterDto(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object> get props => [startDate ?? '', endDate ?? ''];
}
