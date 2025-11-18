import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../router/routes.dart';
import '../../../shared/helpers/app_assets.dart';
import '../../../shared/providers/common_providers.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/bottom_modal.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/svg_widget.dart';
import '../../../translations/locale_keys.g.dart';
import '../providers/profile_providers.dart';
import '../widgets/download_payroll.dart';
import '../widgets/salary_type_card.dart';
import '../widgets/vehicle_details_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            VerticalSpace(space: 30),
            _Header(),
            VerticalSpace(space: 30),
            _FinancialList(),
            VerticalSpace(space: 30),
            _VehicleDetails(),
            VerticalSpace(space: 30),
            _Logout()
          ],
        ),
      ),
    );
  }
}

class _Logout extends ConsumerWidget {
  const _Logout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
      ),
      child: Button(
        label: LocaleKeys.logout.tr(),
        onPressed: () {
          ref.read(logoutProvider.notifier).logout();
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: 20.h,
              left: 20.w,
              right: 10.w,
              bottom: 20.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Consumer(
                    builder: (_, ref, __) {
                      final user = ref.watch(loggedInUserProvider);

                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 40.r,
                            backgroundImage: NetworkImage(
                              user.avatar,
                            ),
                          ),
                          const HorizontalSpace(space: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .displayMedium,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                VerticalSpace(space: 5.h),
                                Text(
                                  user.email,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .displaySmall!
                                      .copyWith(
                                        color: SECONDARY_TEXT_COLOR,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const HorizontalSpace(),
                IconButton(
                  onPressed: () {
                    context.push(Routes.editProfile);
                  },
                  icon: SvgWidget(
                    imagePath: EDIT_ICON,
                    width: 24.w,
                  ),
                ),
              ],
            ),
          ),
          const VerticalSpace(space: 30),
          Row(
            children: [
              Expanded(
                child: Button(
                  label: LocaleKeys.payroll_download.tr(),
                  isSecondary: true,
                  onPressed: () {
                    showBottomModal(
                      context: context,
                      height: 450.w,
                      child: const DownloadPayroll(),
                    );
                  },
                ),
              ),
              const HorizontalSpace(space: 20),
              Expanded(
                child: Button(
                  label: LocaleKeys.request_advance.tr(),
                  onPressed: () {
                    // navigate to request advance page
                    context.push(Routes.requestAdvance);
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _FinancialList extends ConsumerWidget {
  const _FinancialList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salaryTypesList = ref.watch(salaryTypesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            LocaleKeys.salary_details.tr(),
            style: Theme.of(context).primaryTextTheme.displayMedium,
          ),
        ),
        const VerticalSpace(space: 20),
        SizedBox(
          height: 150.w,
          child: salaryTypesList.when(
            data: (salaryTypes) {
              return ListView.separated(
                itemCount: salaryTypes.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      left: index == 0 ? 24.w : 0,
                      right: index == salaryTypes.length - 1 ? 24.w : 0,
                    ),
                    child: SalaryTypeCard(
                      amount: salaryTypes[index].amount,
                      label: salaryTypes[index].type.tr(),
                      length: "${salaryTypes[index].count}",
                      onTap: () {
                        context.push(salaryTypes[index].route);
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const HorizontalSpace(space: 20);
                },
              );
            },
            error: ((error, stackTrace) {
              return Text(
                error.toString(),
                textAlign: TextAlign.center,
              );
            }),
            loading: () {
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VehicleDetails extends ConsumerWidget {
  const _VehicleDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.vehicle_details.tr(),
            style: Theme.of(context).primaryTextTheme.displayMedium,
          ),
          const VerticalSpace(space: 20),
          ref.watch(assignedVehicleProvider).when(
            data: (vehicle) {
              if (vehicle != null) {
                return VehicleDetailsCard(
                  vehicle: vehicle,
                );
              } else {
                return Button(
                  label: LocaleKeys.request_vehicle.tr(),
                  onPressed: () {
                    context.push(Routes.requestVehicle);
                  },
                );
              }
            },
            error: (error, stackTrace) {
              return Text(error.toString());
            },
            loading: () {
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}
