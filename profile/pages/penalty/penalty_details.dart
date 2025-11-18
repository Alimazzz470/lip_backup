import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taxiapp_mobile/core/dto/image_slider.dart';
import 'package:taxiapp_mobile/core/services/image_helpers.dart';
import 'package:taxiapp_mobile/features/profile/providers/penalty_provider.dart';
import 'package:taxiapp_mobile/router/routes.dart';
import 'package:taxiapp_mobile/shared/theme/app_colors.dart';
import 'package:taxiapp_mobile/shared/utils/date_time.dart';
import 'package:taxiapp_mobile/shared/widgets/padding.dart';
import 'package:taxiapp_mobile/translations/locale_keys.g.dart';

class PenaltyDetailsScreen extends ConsumerWidget {
  final String penaltyId;

  const PenaltyDetailsScreen({super.key, required this.penaltyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final singlePenaltyProvider =
        ref.watch(getSinglePenaltyProvider(penaltyId));
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Penalty Details',
            style: Theme.of(context).primaryTextTheme.displayLarge,
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              ref.invalidate(penaltyProvider);
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
                child: singlePenaltyProvider.when(
                    data: (penalty) => SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const VerticalSpace(
                                space: 20,
                              ),
                              Text(
                                LocaleKeys.title.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const VerticalSpace(
                                space: 15,
                              ),
                              Text(
                                penalty.subject,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: SECONDARY_TEXT_COLOR),
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
                                penalty.description,
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
                                  penalty.createdAt.toIso8601String(),
                                ).dateText} ${DateTime.parse(
                                  penalty.createdAt.toIso8601String(),
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
                              penalty.urls.isNotEmpty
                                  ? SizedBox(
                                      height: 100.h,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: penalty.urls.length,
                                        itemBuilder: (context, index) {
                                          return FutureBuilder<String>(
                                            future: getContentType(
                                                penalty.urls[index]),
                                            builder: (context, snapshot) {
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                    right: 10.w),
                                                child: snapshot.hasData
                                                    ? snapshot.data!
                                                            .contains('image')
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              final imagesOnly = penalty
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
                                                                  penalty.urls[
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
                                                                    penalty.urls[
                                                                        index]);
                                                              } else {
                                                                await openUrl(
                                                                    penalty.urls[
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
                                                                      penalty
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
                                '€ ${penalty.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: SECONDARY_TEXT_COLOR),
                              ),
                              const VerticalSpace(
                                space: 40,
                              ),
                            ],
                          ),
                        ),
                    error: (error, stacktrace) => Container(),
                    loading: () =>
                        const Center(child: CircularProgressIndicator())))));
  }
}
