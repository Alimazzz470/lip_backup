import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:taxiapp_mobile/features/chat/providers/messages_provider.dart';
import 'package:taxiapp_mobile/features/profile/providers/profile_providers.dart';
import 'package:taxiapp_mobile/shared/providers/common_providers.dart';
import '../../../core/exceptions/coded_exception.dart';
import '../../../router/routes.dart';
import '../../../shared/helpers/app_assets.dart';
import '../../../shared/helpers/coded_exception_helper.dart';
import '../../../shared/widgets/bottom_modal.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/placeholders/placeholder_content.dart';
import '../../../translations/locale_keys.g.dart';
import '../providers/get_notifications_providers.dart';
import '../providers/inspection_provider.dart';
import '../providers/time_logs_providers.dart';
import '../widgets/download_filter.dart';
import '../widgets/inspection.dart';
import '../widgets/time_tracker.dart';
import '../widgets/timeline_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeProvider = ref.watch(localizationProvider);
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24.w,
            right: 24.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const VerticalSpace(space: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 50.h,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            context.push(Routes.notifications);
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                                height: 40.h,
                                width: 40.w,
                                child: SvgPicture.asset(NOTIFICATION_ICON)),
                          ),
                        ),
                        // add a red dot if there are notifications
                        ref.watch(notificationsProvider).when(
                            error: (error, stackTrace) {
                              return Container();
                            },
                            loading: () => Container(),
                            data: (data) => data.data.isNotEmpty
                                ? Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      height: 22.h,
                                      width: 22.w,
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          data.data.length.toString(),
                                          style: Theme.of(context)
                                              .primaryTextTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Colors.white,
                                              ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container()),
                      ],
                    ),
                  ),
                  const HorizontalSpace(space: 15),
                  GestureDetector(
                    child: SizedBox(
                      height: 50.h,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.push(Routes.chats);
                            },
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                  height: 40.h,
                                  width: 40.w,
                                  child: SvgPicture.asset(
                                    INACTIVE_CHAT_ICON,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.srcATop,
                                    ),
                                  )),
                            ),
                          ),
                          ref.watch(unreadCountProvider).when(
                              error: (error, stackTrace) {
                                debugPrint("Error Here $error");
                                return Container();
                              },
                              loading: () => Container(),
                              data: (data) {
                                return data != 0
                                    ? Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          height: 22.h,
                                          width: 22.w,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              data.toString(),
                                              style: Theme.of(context)
                                                  .primaryTextTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container();
                              }),
                        ],
                      ),
                    ),
                  ),
                  const HorizontalSpace(space: 15),
                  GestureDetector(
                    child: SizedBox(
                      height: 50.h,
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(localizationProvider.notifier)
                                  .changeLocale(
                                      localeProvider.languageCode == 'en'
                                          ? const Locale('de')
                                          : const Locale('en'),
                                      context);
                            },
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                  height: 40.h,
                                  width: 40.w,
                                  child: SvgPicture.asset(
                                    LANGUAGE_ICON,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.black,
                                      BlendMode.srcATop,
                                    ),
                                  )),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              height: 22.h,
                              width: 22.w,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  localeProvider.languageCode,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const VerticalSpace(space: 20),
              ref.watch(assignedVehicleProvider).when(
                data: (vehicle) {
                  if (vehicle != null) {
                    return const Column(
                      children: [
                        TimeTracker(),
                        VerticalSpace(space: 30),
                      ],
                    );
                  } else {
                    return Container(
                      height: 180.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Center(
                        child: Text(
                          LocaleKeys.no_vehicle_assigned.tr(),
                          style: Theme.of(context)
                              .primaryTextTheme
                              .displaySmall
                              ?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
              Consumer(
                builder: (_, ref, __) {
                  final inspection = ref.watch(hasInspectionProvider);

                  return inspection.maybeWhen(
                    data: (data) {
                      if (data == null || data.completed) {
                        return const SizedBox.shrink();
                      } else {
                        return Column(
                          children: [
                            Inspection(
                              inspectionId: data.id,
                              vehicleId: data.vehicleId,
                            ),
                            const VerticalSpace(space: 30),
                          ],
                        );
                      }
                    },
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
              Text(
                LocaleKeys.driver_logs.tr(),
                style: Theme.of(context).primaryTextTheme.displayMedium,
              ),
              const VerticalSpace(space: 15),
              Row(
                children: [
                  Flexible(
                    child: Button(
                      label: LocaleKeys.view_all.tr(),
                      onPressed: () {
                        context.push(Routes.driverHours);
                      },
                    ),
                  ),
                  const HorizontalSpace(space: 15),
                  Flexible(
                    child: Button(
                      label: LocaleKeys.download.tr(),
                      onPressed: () {
                        showBottomModal(
                          context: context,
                          height: 280.w,
                          child: const DownloadFilter(),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const VerticalSpace(space: 30),
              Text(
                LocaleKeys.today_hours.tr(),
                style: Theme.of(context).primaryTextTheme.displayMedium,
              ),
              const VerticalSpace(space: 20),
              const _TodayHours(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayHours extends ConsumerWidget {
  const _TodayHours({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayLog = ref.watch(todayLogProvider);

    return todayLog.when(
      data: (timeline) {
        if (timeline.isEmpty) {
          return Center(
            child: Text(
              LocaleKeys.not_started_working.tr(),
              style: Theme.of(context).primaryTextTheme.displaySmall!.copyWith(
                    color: Colors.grey,
                  ),
            ),
          );
        }

        return ListView.separated(
          itemCount: timeline.length,
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return TimelineCard(
              index: index,
              length: timeline.length,
              timeline: timeline[index],
            );
          },
          separatorBuilder: (context, index) {
            return const VerticalSpace(space: 1);
          },
        );
      },
      error: (error, stackTrace) {
        final e = error as CodedException;
        return PlaceholderContent(
          message: e.getString(context),
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
