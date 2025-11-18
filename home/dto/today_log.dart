import 'package:equatable/equatable.dart';

import '../../../shared/utils/date_time.dart';

class TodayLogDto extends Equatable {
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? breakStarted;
  final DateTime? breakEnded;

  const TodayLogDto({
    this.startTime,
    this.endTime,
    this.breakStarted,
    this.breakEnded,
  });

  const TodayLogDto.empty()
      : startTime = null,
        endTime = null,
        breakStarted = null,
        breakEnded = null;

  @override
  List<Object> get props => [
        startTime ?? '',
        endTime ?? '',
        breakStarted ?? '',
        breakEnded ?? '',
      ];

  String get startTimeString => startTime != null ? formatTime(startTime!) : '';

  String get endTimeString => endTime != null ? formatTime(endTime!) : '';

  String get breakStartedString =>
      breakStarted != null ? formatTime(breakStarted!) : '';

  String get breakEndedString =>
      breakEnded != null ? formatTime(breakEnded!) : '';
}
