import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/entities/vehicle/vehicle.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/toast.dart';
import '../../../translations/locale_keys.g.dart';
import '../providers/request_vehicle_providers.dart';

class RequestCarBody extends ConsumerWidget {
  final Vehicle vehicle;

  const RequestCarBody({
    required this.vehicle,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(requestVehicleProvider);

    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Padding(
            padding: EdgeInsets.symmetric(
              vertical: 30.h,
              horizontal: 24.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.vehicle_details.tr(),
                  style: Theme.of(context).primaryTextTheme.displayMedium,
                ),
                const VerticalSpace(space: 15),
                Container(
                  height: 1.h,
                  color: SECONDARY_TEXT_COLOR,
                ),
                const VerticalSpace(space: 40),
                _RowWidget(
                  label: LocaleKeys.vehicle_brand.tr(),
                  value: vehicle.brand,
                ),
                const VerticalSpace(space: 25),
                _RowWidget(
                  label: LocaleKeys.vehicle_model.tr(),
                  value: vehicle.model,
                ),
                const VerticalSpace(space: 25),
                _RowWidget(
                  label: LocaleKeys.vehicle_plate.tr(),
                  value: vehicle.vehicleNumber,
                ),
                const VerticalSpace(space: 25),
                _RowWidget(
                  label: LocaleKeys.vehicle_color.tr(),
                  value: vehicle.color,
                ),
                const VerticalSpace(space: 25),
                _RowWidget(
                  label: LocaleKeys.status.tr(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: vehicle.user == null ? SUCCESS_COLOR : ERROR_COLOR,
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Text(
                      vehicle.user == null ? LocaleKeys.available.tr() : LocaleKeys.occupied.tr(),
                      style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
                const Spacer(),
                Button(
                  label: LocaleKeys.request.tr(),
                  onPressed: () {
                    if (vehicle.user != null) {
                      context.pop();

                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return _ConfirmDialogBody(
                            vehicleId: vehicle.id,
                            vehicleNumber: vehicle.vehicleNumber,
                          );
                        },
                      );
                    } else {
                      ref.read(requestVehicleProvider.notifier).requestVehicle(
                            vehicleTypeId: vehicle.id,
                            onSuccess: () {
                              context.pop();

                              showSuccessSnackBar(
                                context,
                                message: LocaleKeys.success_vehicle_assigned.tr(),
                              );
                            },
                          );
                    }
                  },
                )
              ],
            ),
          );
  }
}

class _RowWidget extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? child;

  const _RowWidget({
    required this.label,
    this.value,
    this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).primaryTextTheme.bodyLarge,
        ),
        child ??
            Text(
              value!,
              style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                    color: SECONDARY_TEXT_COLOR,
                  ),
            ),
      ],
    );
  }
}

class _ConfirmDialogBody extends StatelessWidget {
  final String vehicleId;
  final String vehicleNumber;

  const _ConfirmDialogBody({
    required this.vehicleId,
    required this.vehicleNumber,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              LocaleKeys.vehicle_already_booked.tr(),
              style: Theme.of(context).primaryTextTheme.displayMedium,
            ),
            const VerticalSpace(space: 30),
            Text(
              LocaleKeys.vehicle_already_booked_description.tr(args: [vehicleNumber]),
              style: Theme.of(context).primaryTextTheme.displaySmall!.copyWith(
                    color: SECONDARY_TEXT_COLOR,
                  ),
              textAlign: TextAlign.center,
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
                  child: Consumer(
                    builder: (_, ref, __) {
                      return Button(
                        label: LocaleKeys.request.tr(),
                        onPressed: () {
                          ref.read(requestVehicleProvider.notifier).requestVehicle(
                                vehicleTypeId: vehicleId,
                                onSuccess: () {
                                  context.pop();

                                  showSuccessSnackBar(
                                    context,
                                    message: LocaleKeys.success_vehicle_assigned.tr(),
                                  );
                                },
                              );
                        },
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
  }
}
