import 'package:equatable/equatable.dart';

class TimerDto extends Equatable {
  final int hours;
  final int minutes;
  final int seconds;

  const TimerDto({
    required this.hours,
    required this.minutes,
    required this.seconds,
  });

  const TimerDto.empty()
      : hours = 0,
        minutes = 0,
        seconds = 0;

  TimerDto copyWith({
    int? hours,
    int? minutes,
    int? seconds,
  }) {
    return TimerDto(
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
    );
  }

  String toFormattedString() {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object> get props => [hours, minutes, seconds];
}
