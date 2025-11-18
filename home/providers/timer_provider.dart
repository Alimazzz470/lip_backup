import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dto/timer.dart';
import 'time_tracking_providers.dart';

final timerNotifierProvider =
    NotifierProvider.autoDispose<TimerNotifier, TimerDto>(TimerNotifier.new);

class TimerNotifier extends AutoDisposeNotifier<TimerDto> {
  Timer? _timer;
  int _seconds = 0;
  int _minutes = 0;
  int _hours = 0;

  @override
  TimerDto build() {
    final status = ref.watch(statusProvider);

    if (status.timeTrackingRunning) {
      final int seconds = status.workedTime ~/ 1000;
      final bool isOnBreak = status.timeTrackingBreakRunning;
      if (seconds > 0) {
        resume(seconds: seconds, isOnBreak: isOnBreak);
      }
    }

    ref.onDispose(() {
      _timer?.cancel();
    });

    return TimerDto(
      hours: _hours,
      minutes: _minutes,
      seconds: _seconds,
    );
  }

  void start() {
    _startTimer();
  }

  void resume({
    required int seconds,
    required bool isOnBreak,
  }) {
    _timer?.cancel();

    _hours = seconds ~/ 3600;
    _minutes = (seconds % 3600) ~/ 60;
    _seconds = seconds % 60;

    if (isOnBreak) return;

    _startTimer();
  }

  void stop() {
    _timer?.cancel();

    _seconds = 0;
    _minutes = 0;
    _hours = 0;

    state = const TimerDto.empty();
  }

  void pause() {
    _timer?.cancel();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _seconds++;
      if (_seconds == 60) {
        _seconds = 0;
        _minutes++;
      }
      if (_minutes == 60) {
        _minutes = 0;
        _hours++;
      }
      state = state.copyWith(
        hours: _hours,
        minutes: _minutes,
        seconds: _seconds,
      );
    });
  }
}
