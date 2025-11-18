import 'package:equatable/equatable.dart';

import '../../../core/dto/option.dart';

class LeavesFilterDto extends Equatable {
  final String? status;
  final Option? type;
  final DateTime? startDate;
  final DateTime? endDate;

  const LeavesFilterDto({this.status, this.type, this.startDate, this.endDate});

  factory LeavesFilterDto.empty() {
    return const LeavesFilterDto(
      status: null,
      type: null,
      startDate: null,
      endDate: null,
    );
  }

  LeavesFilterDto copyWith({
    String? status,
    Option? type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return LeavesFilterDto(
      status: status ?? this.status,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object> get props => [status ?? '', type ?? '', startDate ?? '', endDate ?? ''];
}
