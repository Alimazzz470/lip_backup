import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taxiapp_mobile/features/profile/providers/profile_providers.dart';

import '../../../core/entities/time_tracking_status.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/date_time.dart';
import '../../../shared/widgets/bottom_modal.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/primary_text_field.dart';
import '../../../shared/widgets/signature_view.dart';
import '../../../shared/widgets/toast.dart';
import '../../../translations/locale_keys.g.dart';
import '../providers/time_tracking_providers.dart';
import '../providers/timer_provider.dart';

class TimeTracker extends ConsumerStatefulWidget {
  const TimeTracker({super.key});

  @override
  ConsumerState<TimeTracker> createState() => _TimeTrackerState();
}

class _TimeTrackerState extends ConsumerState<TimeTracker>
    with WidgetsBindingObserver {
  String? _startKm;
  String? _endKm;
  DateTime? _startTime;
  DateTime? _endTime;

  late final TextEditingController _startTimeController;
  late final TextEditingController _endTimeController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();

    ref.read(timeTrackingNotifierProvider.notifier).init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(timeTrackingNotifierProvider.notifier).init();
    }
  }

  bool _isValidInput(String? km, DateTime? time) {
    return km != null && km.isNotEmpty && time != null;
  }

  void _handleTracking(bool isStart, String? km, DateTime? time) {
    if (!_isValidInput(km, time)) return;

    var notifier = ref.read(timeTrackingNotifierProvider.notifier);
    if (isStart) {
      notifier.startTracking(
        startKm: km!,
        startTime: time!.toUtc().toString().replaceAll(" ", "T"),
        onSuccess: () {
          _startTimeController.clear();
          context.pop();
        },
      );
    } else {
      showBottomModal(
        context: context,
        height: 720.w,
        child: SignatureView(
          onSigned: (bytes) {
            if (bytes == null) return;
            context.pop();

            final id = ref.read(timeTrackingIdProvider);

            notifier.stopTracking(
              timeTrackingId: id,
              endKm: km!,
              endTime: time!.toUtc().toString().replaceAll(" ", "T"),
              imageBytes: bytes,
              onSuccess: () {
                _endTimeController.clear();
                context.pop();
              },
            );
          },
        ),
      );
    }

    FocusScope.of(context).unfocus();
  }

  void _handleBreak(bool isStart, DateTime? time) {
    if (time == null) return;

    var notifier = ref.read(timeTrackingNotifierProvider.notifier);
    if (isStart) {
      notifier.startBreak(
        startTime: time.toUtc().toString().replaceAll(" ", "T"),
        onSuccess: () {
          _startTimeController.clear();
          context.pop();
        },
      );
    } else {
      notifier.stopBreak(
        endTime: time.toUtc().toString().replaceAll(" ", "T"),
        onSuccess: () {
          _endTimeController.clear();
          context.pop();
        },
      );
    }

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 20.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Column(
        children: [
          Consumer(
            builder: (_, ref, __) {
              final timer = ref.watch(timerNotifierProvider);
              return Text(
                timer.toFormattedString(),
                style: Theme.of(context).primaryTextTheme.titleLarge,
              );
            },
          ),
          const VerticalSpace(space: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${LocaleKeys.enter_km.tr()}: ",
                style:
                    Theme.of(context).primaryTextTheme.displaySmall!.copyWith(
                          color: SECONDARY_TEXT_COLOR,
                        ),
              ),
              Consumer(
                builder: (_, ref, __) {
                  final vehicle = ref.watch(assignedVehicleProvider);
                  return vehicle.when(
                      data: (data) => Text(
                            data!.milage,
                            style: Theme.of(context)
                                .primaryTextTheme
                                .displaySmall!
                                .copyWith(
                                  color: SECONDARY_TEXT_COLOR,
                                ),
                          ),
                      error: (e, stacktrace) => Container(),
                      loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ));
                },
              ),
            ],
          ),
          const VerticalSpace(space: 20),
          Divider(
            color: SECONDARY_TEXT_COLOR.withOpacity(0.2),
            height: 2.h,
          ),
          const VerticalSpace(space: 20),
          Consumer(
            builder: (_, ref, __) {
              final status = ref.watch(statusProvider);

              if (status.timeTrackingRunning &&
                  !status.timeTrackingBreakRunning) {
                return Row(
                  children: [
                    if (status.breaksTime == 0) ...[
                      Expanded(
                        child: Button(
                          label: LocaleKeys.start_break.tr(),
                          onPressed: () {
                            showStarEndBreakDialog(status: status);
                          },
                        ),
                      ),
                      const HorizontalSpace(space: 20),
                    ],
                    Expanded(
                      child: Button(
                        label: LocaleKeys.end_shift.tr(),
                        onPressed: () {
                          showStartEndTrackingDialog(status: status);
                        },
                      ),
                    ),
                  ],
                );
              }

              if (status.timeTrackingRunning &&
                  status.timeTrackingBreakRunning) {
                return Button(
                  label: LocaleKeys.end_break.tr(),
                  onPressed: () {
                    showStarEndBreakDialog(status: status);
                  },
                );
              }

              return Button(
                label: LocaleKeys.start.tr(),
                onPressed: () {
                  if (status.isAvailableForTimeTracking) {
                    showStartEndTrackingDialog();
                  } else {
                    showInfoSnackBar(
                      context,
                      message: LocaleKeys.error_multiple_time_trackings.tr(),
                    );
                  }
                },
              );
            },
          )
        ],
      ),
    );
  }

  void showStarEndBreakDialog({
    TimeTrackingStatus status = const TimeTrackingStatus.empty(),
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(
            horizontal: 24.w,
          ),
          content: Container(
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.only(
              top: 20.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status.timeTrackingBreakRunning
                      ? LocaleKeys.end_break.tr()
                      : LocaleKeys.start_break.tr(),
                  style: Theme.of(context).primaryTextTheme.titleMedium,
                ),
                const VerticalSpace(space: 20),
                PrimaryTextField(
                  controller: status.timeTrackingBreakRunning
                      ? _endTimeController
                      : _startTimeController,
                  hintText: status.timeTrackingBreakRunning
                      ? LocaleKeys.end_time.tr()
                      : LocaleKeys.start_time.tr(),
                  readOnly: true,
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (selectedTime == null) return;

                    if (status.timeTrackingBreakRunning) {
                      _endTimeController.text =
                          timeOfDayToDateTime(selectedTime).timeText;
                      _endTime = timeOfDayToDateTime(selectedTime);
                    } else {
                      _startTimeController.text =
                          timeOfDayToDateTime(selectedTime).timeText;
                      _startTime = timeOfDayToDateTime(selectedTime);
                    }
                  },
                ),
                const VerticalSpace(space: 30),
                Row(
                  children: [
                    Expanded(
                      child: Button(
                        label: LocaleKeys.cancel.tr(),
                        isSecondary: true,
                        onPressed: () {
                          context.pop();
                        },
                      ),
                    ),
                    const HorizontalSpace(space: 10),
                    Expanded(
                      child: Button(
                        label: status.timeTrackingBreakRunning
                            ? LocaleKeys.end.tr()
                            : LocaleKeys.start.tr(),
                        onPressed: () async {
                          _handleBreak(
                            !status.timeTrackingBreakRunning,
                            status.timeTrackingBreakRunning
                                ? _endTime
                                : _startTime,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showStartEndTrackingDialog({
    TimeTrackingStatus status = const TimeTrackingStatus.empty(),
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.r),
          ),
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(
            horizontal: 24.w,
          ),
          content: Container(
            width: MediaQuery.sizeOf(context).width,
            padding: EdgeInsets.only(
              top: 20.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status.timeTrackingRunning
                      ? LocaleKeys.end_shift.tr()
                      : LocaleKeys.start_shift.tr(),
                  style: Theme.of(context).primaryTextTheme.titleMedium,
                ),
                const VerticalSpace(space: 20),
                PrimaryTextField(
                  hintText: status.timeTrackingRunning
                      ? LocaleKeys.end_km.tr()
                      : LocaleKeys.start_km.tr(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (status.timeTrackingRunning) {
                      _endKm = value;
                    } else {
                      _startKm = value;
                    }
                  },
                ),
                const VerticalSpace(space: 20),
                PrimaryTextField(
                  controller: status.timeTrackingRunning
                      ? _endTimeController
                      : _startTimeController,
                  hintText: status.timeTrackingRunning
                      ? LocaleKeys.end_time.tr()
                      : LocaleKeys.start_time.tr(),
                  readOnly: true,
                  onTap: () async {
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );

                    if (selectedTime == null) return;

                    if (status.timeTrackingRunning) {
                      _endTimeController.text =
                          timeOfDayToDateTime(selectedTime).timeText;
                      _endTime = timeOfDayToDateTime(selectedTime);
                    } else {
                      _startTimeController.text =
                          timeOfDayToDateTime(selectedTime).timeText;
                      _startTime = timeOfDayToDateTime(selectedTime);
                    }
                  },
                ),
                const VerticalSpace(space: 30),
                Row(
                  children: [
                    Expanded(
                      child: Button(
                        label: LocaleKeys.cancel.tr(),
                        isSecondary: true,
                        onPressed: () {
                          context.pop();
                        },
                      ),
                    ),
                    const HorizontalSpace(space: 10),
                    Expanded(
                      child: Button(
                        label: status.timeTrackingRunning
                            ? LocaleKeys.end.tr()
                            : LocaleKeys.start.tr(),
                        onPressed: () async {
                          _handleTracking(
                            !status.timeTrackingRunning,
                            status.timeTrackingRunning ? _endKm : _startKm,
                            status.timeTrackingRunning ? _endTime : _startTime,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
