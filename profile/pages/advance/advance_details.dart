import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taxiapp_mobile/core/dto/image_slider.dart';
import 'package:taxiapp_mobile/core/services/image_helpers.dart';
import 'package:taxiapp_mobile/features/profile/profile_extensions.dart';
import 'package:taxiapp_mobile/features/profile/providers/advances_provider.dart';
import 'package:taxiapp_mobile/router/routes.dart';
import 'package:taxiapp_mobile/shared/theme/app_colors.dart';
import 'package:taxiapp_mobile/shared/utils/date_time.dart';
import 'package:taxiapp_mobile/shared/widgets/padding.dart';
import 'package:taxiapp_mobile/translations/locale_keys.g.dart';

class AdvanceDetailsScreen extends ConsumerWidget {
  final String advanceId;

  const AdvanceDetailsScreen({super.key, required this.advanceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final singleAdvanceProvider =
        ref.watch(getSingleAdvanceProvider(advanceId));
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Advance Details',
            style: Theme.of(context).primaryTextTheme.displayLarge,
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              ref.invalidate(advancesProvider);
              context.pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 20.h),
                child: singleAdvanceProvider.when(
                    data: (advanceData) => SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const VerticalSpace(
                                space: 20,
                              ),
                              Text(
                                LocaleKeys.status.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const VerticalSpace(
                                space: 15,
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: Border.all(
                                    color: advanceData.status.color,
                                  ),
                                ),
                                child: Text(
                                  advanceData.status.name,
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .displaySmall!
                                      .copyWith(
                                        color: advanceData.status.color,
                                      ),
                                ),
                              ),
                              const VerticalSpace(
                                space: 30,
                              ),
                              Text(
                                LocaleKeys.description.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const VerticalSpace(
                                space: 15,
                              ),
                              Text(
                                advanceData.description,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: SECONDARY_TEXT_COLOR),
                              ),
                              const VerticalSpace(
                                space: 30,
                              ),
                              Text(
                                LocaleKeys.created_date.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const VerticalSpace(
                                space: 15,
                              ),
                              Text(
                                '${DateTime.parse(
                                  advanceData.createdAt.toIso8601String(),
                                ).dateText} ${DateTime.parse(
                                  advanceData.createdAt.toIso8601String(),
                                ).timeText}',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: SECONDARY_TEXT_COLOR),
                              ),
                              const VerticalSpace(
                                space: 30,
                              ),
                              Text(
                                LocaleKeys.images_files.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const VerticalSpace(
                                space: 15,
                              ),
                              advanceData.urls.isNotEmpty
                                  ? SizedBox(
                                      height: 100.h,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: advanceData.urls.length,
                                        itemBuilder: (context, index) {
                                          return FutureBuilder<String>(
                                            future: getContentType(
                                                advanceData.urls[index]),
                                            builder: (context, snapshot) {
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                    right: 10.w),
                                                child: snapshot.hasData
                                                    ? snapshot.data!
                                                            .contains('image')
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              final imagesOnly = advanceData
                                                                  .urls
                                                                  .where((element) =>
                                                                      element.contains('jpg') ||
                                                                      element.contains(
                                                                          'jpeg') ||
                                                                      element.contains(
                                                                          'png'))
                                                                  .toList();

                                                              context.push(
                                                                Routes
                                                                    .imageSlider,
                                                                extra:
                                                                    ImageSliderDto(
                                                                  images:
                                                                      imagesOnly,
                                                                  initialIndex:
                                                                      index,
                                                                ),
                                                              );
                                                            },
                                                            child: Container(
                                                              width: 150.w,
                                                              height: 100.h,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.r),
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.r),
                                                                child: Image
                                                                    .network(
                                                                  advanceData
                                                                          .urls[
                                                                      index],
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : GestureDetector(
                                                            onTap: () async {
                                                              if (snapshot
                                                                      .data ==
                                                                  'application/pdf') {
                                                                await openFileUrlDoc(
                                                                    advanceData
                                                                            .urls[
                                                                        index]);
                                                              } else {
                                                                await openUrl(
                                                                    advanceData
                                                                            .urls[
                                                                        index]);
                                                              }
                                                            },
                                                            child: Container(
                                                              width: 150.w,
                                                              height: 100.h,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .black,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.r),
                                                              ),
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            20.h),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    const Center(
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .insert_drive_file,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    ),
                                                                    VerticalSpace(
                                                                      space:
                                                                          5.h,
                                                                    ),
                                                                    Text(
                                                                      advanceData
                                                                          .urls[
                                                                              index]
                                                                          .split(
                                                                              '/')
                                                                          .last,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14.sp,
                                                                        color: Colors
                                                                            .white,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                    : Container(
                                                        width: 150.w,
                                                        height: 100.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.r),
                                                        ),
                                                        child: const Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                      ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        LocaleKeys.no_images_available.tr(),
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: SECONDARY_TEXT_COLOR),
                                      ),
                                    ),
                              const VerticalSpace(
                                space: 30,
                              ),
                              if (advanceData.status ==
                                      AdvanceStatus.REJECTED &&
                                  advanceData.rejectReason != null &&
                                  advanceData.rejectReason!.isNotEmpty) ...[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const VerticalSpace(space: 30),
                                    Text(
                                      "${LocaleKeys.reason_for_rejection.tr()}:",
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .bodyLarge!
                                          .copyWith(
                                            color: SECONDARY_TEXT_COLOR,
                                          ),
                                    ),
                                    Text(
                                      advanceData.rejectReason ?? '',
                                      style: Theme.of(context)
                                          .primaryTextTheme
                                          .bodyLarge!
                                          .copyWith(
                                            color: SECONDARY_TEXT_COLOR,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                              Text(
                                LocaleKeys.amount.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const VerticalSpace(
                                space: 15,
                              ),
                              Text(
                                '€ ${advanceData.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: SECONDARY_TEXT_COLOR),
                              ),
                              const VerticalSpace(
                                space: 30,
                              ),
                              Text(
                                'Installment Total Period',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const VerticalSpace(
                                space: 15,
                              ),
                              Text(
                                '${advanceData.installmentPeriod} Months',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: SECONDARY_TEXT_COLOR),
                              ),
                              const VerticalSpace(
                                space: 30,
                              ),
                              Text(
                                'Installments Paid',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const VerticalSpace(
                                space: 15,
                              ),
                              Text(
                                '${advanceData.completedInstallmentPeriod} Months',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: SECONDARY_TEXT_COLOR),
                              ),
                            ],
                          ),
                        ),
                    error: (error, stacktrace) => Center(
                          child: Text('Error: $error'),
                        ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator())))));
  }
}
