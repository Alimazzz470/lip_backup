import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/exceptions/coded_exception.dart';
import '../../../router/routes.dart';
import '../../../shared/helpers/coded_exception_helper.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/placeholders/placeholder_content.dart';
import '../../../translations/locale_keys.g.dart';
import '../dto/leaves_filter.dart';
import '../providers/get_leaves_provider.dart';
import '../widgets/filter_button.dart';
import '../widgets/leave_card.dart';
import '../widgets/leave_type_card.dart';

class LeavesPage extends ConsumerWidget {
  const LeavesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: () async {
              ref.invalidate(leaveTypesProvider);
              ref.invalidate(leaveRequestProvider);
              ref.invalidate(leaveHistoryProvider);
            },
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const VerticalSpace(space: 30),
                    const _AvailableLeaves(),
                    const VerticalSpace(space: 30),
                    const _LeaveRequests(),
                    const VerticalSpace(space: 30),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 24.w,
                        right: 24.w,
                      ),
                      child: const _LeaveHistory(),
                    ),
                    const VerticalSpace(space: 20),
                  ],
                );
              },
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailableLeaves extends ConsumerWidget {
  const _AvailableLeaves({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
          ),
          child: Text(
            LocaleKeys.leave.tr(),
            style: Theme.of(context).primaryTextTheme.displayMedium,
          ),
        ),
        const VerticalSpace(space: 20),
        ref.watch(leaveTypesProvider).when(
              data: (leaveTypes) {
                if (leaveTypes.isEmpty) {
                  return SizedBox(
                    height: 120.w,
                    child: Center(
                      child: Text(
                        LocaleKeys.no_leave_types.tr(),
                        style: Theme.of(context)
                            .primaryTextTheme
                            .displaySmall!
                            .copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 120.w,
                  child: PageView.builder(
                    itemCount: (leaveTypes.length / 3).ceil(),
                    itemBuilder: (context, index) {
                      final startIndex = index * 3;
                      final endIndex = (index + 1) * 3;
                      final pageLeaves = leaveTypes.sublist(
                          startIndex, endIndex.clamp(0, leaveTypes.length));

                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (var type in pageLeaves)
                              LeaveTypeCard(
                                leaveType: type,
                              ),

                            // Add empty containers if there are fewer than 3 items on any page
                            if (pageLeaves.length < 3)
                              ...List.generate(
                                3 - pageLeaves.length,
                                (index) => SizedBox(
                                  width: 120.w,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => SizedBox(
                height: 120.w,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              error: (error, stackTrace) {
                final e = error as CodedException;
                return SizedBox(
                  height: 120.w,
                  child: PlaceholderContent(
                    message: e.getString(context),
                  ),
                );
              },
            ),
        const VerticalSpace(space: 25),
        const RequestLeaveButton(),
      ],
    );
  }
}

class _LeaveRequests extends ConsumerWidget {
  const _LeaveRequests();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ref.watch(leaveRequestProvider).when(
              data: (leaves) {
                if (leaves.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 24.w,
                          right: 24.w,
                        ),
                        child: Text(
                          LocaleKeys.leave_request.tr(),
                          style:
                              Theme.of(context).primaryTextTheme.displayMedium,
                        ),
                      ),
                      const VerticalSpace(space: 20),
                      SizedBox(
                        height: 94.h,
                        child: Center(
                          child: Text(
                            LocaleKeys.no_leave_request.tr(),
                            style: Theme.of(context)
                                .primaryTextTheme
                                .displaySmall!
                                .copyWith(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: 24.w,
                        right: 24.w,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.leave_request.tr(),
                            style: Theme.of(context)
                                .primaryTextTheme
                                .displayMedium,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 15.w),
                            child: Container(
                              width: 30.w,
                              height: 30.w,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  leaves.length.toString(),
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              context.push(
                                Routes.allLeave,
                                extra:
                                    LeavesFilterDto(startDate: DateTime.now()),
                              );
                            },
                            child: Text(
                              LocaleKeys.see_more.tr(),
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: SECONDARY_TEXT_COLOR,
                                    decoration: TextDecoration.underline,
                                    decorationColor: SECONDARY_TEXT_COLOR,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalSpace(space: 20),
                    SizedBox(
                      height: 94.h,
                      child: ListView.separated(
                        itemCount: leaves.length,
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              left: index == 0 ? 24.w : 0,
                              right: index == leaves.length - 1 ? 24.w : 0,
                            ),
                            child: LeaveCard(
                              width: 272.w,
                              leave: leaves[index],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const HorizontalSpace(space: 20);
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => SizedBox(
                height: 94.h,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              error: (error, stackTrace) {
                final e = error as CodedException;
                return SizedBox(
                  height: 94.h,
                  child: PlaceholderContent(
                    message: e.getString(context),
                  ),
                );
              },
            ),
      ],
    );
  }
}

class _LeaveHistory extends ConsumerWidget {
  const _LeaveHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.leave_history.tr(),
              style: Theme.of(context).primaryTextTheme.displayMedium,
            ),
            GestureDetector(
              onTap: () {
                context.push(
                  Routes.allLeave,
                  extra: LeavesFilterDto(endDate: DateTime.now()),
                );
              },
              child: Text(
                LocaleKeys.see_more.tr(),
                style: Theme.of(context).primaryTextTheme.bodyLarge!.copyWith(
                      color: SECONDARY_TEXT_COLOR,
                      decoration: TextDecoration.underline,
                      decorationColor: SECONDARY_TEXT_COLOR,
                    ),
              ),
            ),
          ],
        ),
        const VerticalSpace(space: 20),
        ref.watch(leaveHistoryProvider).when(
          data: (leaves) {
            if (leaves.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(
                  top: 85.h,
                ),
                child: Text(
                  LocaleKeys.no_leave_history.tr(),
                  style: Theme.of(context)
                      .primaryTextTheme
                      .displaySmall!
                      .copyWith(color: Colors.grey),
                ),
              );
            }

            return ListView.separated(
              itemCount: leaves.length,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return LeaveCard(
                  leave: leaves[index],
                );
              },
              separatorBuilder: (context, index) {
                return const VerticalSpace(space: 20);
              },
            );
          },
          loading: () {
            return Padding(
              padding: EdgeInsets.only(
                top: 85.h,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              ),
            );
          },
          error: (error, stackTrace) {
            final e = error as CodedException;
            return SizedBox(
              height: 85.h,
              child: PlaceholderContent(
                message: e.getString(context),
              ),
            );
          },
        ),
      ],
    );
  }
}
