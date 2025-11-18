import 'package:equatable/equatable.dart';

class LogFilterDto extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;

  const LogFilterDto({this.startDate, this.endDate});

  factory LogFilterDto.empty() {
    return const LogFilterDto(
      startDate: null,
      endDate: null,
    );
  }

  LogFilterDto copyWith({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return LogFilterDto(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  List<Object> get props => [startDate ?? '', endDate ?? ''];
}
