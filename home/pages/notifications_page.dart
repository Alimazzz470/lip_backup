import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:taxiapp_mobile/translations/locale_keys.g.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/no_data_placeholder.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/placeholders/empty_list_placeholder.dart';
import '../providers/get_notifications_providers.dart';
import '../widgets/notifications.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_loadMoreListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMoreListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMoreListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.notification.tr(),
          style: Theme.of(context).primaryTextTheme.displayLarge,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
          child: ref.watch(notificationsProvider).when(
        data: (notifications) {
          return Column(
            children: [
              SizedBox(
                height: 30.h,
              ),
              // add a mark as read button
              Visibility(
                visible: notifications.data.isNotEmpty,
                child: GestureDetector(
                  onTap: () {
                    ref
                        .read(notificationsProvider.notifier)
                        .markAllAsRead(dateTime: DateTime.now());
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 13.h,
                          ),
                          decoration: BoxDecoration(
                            color: PRIMARY_COLOR,
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Text(
                            LocaleKeys.mark_read.tr(),
                            style: Theme.of(context)
                                .primaryTextTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              notifications.data.isNotEmpty
                  ? Expanded(
                      child: RefreshIndicator(
                          backgroundColor: Colors.white,
                          onRefresh: () async {
                            ref.invalidate(notificationsProvider);
                          },
                          child: ListView.separated(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: notifications.data.length +
                                (notifications.hasNextPage ? 1 : 0),
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                            ),
                            itemBuilder: (context, index) {
                              if (index == notifications.data.length) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return NotificationWidget(
                                notification: notifications.data[index],
                              );
                            },
                            separatorBuilder: (context, index) {
                              return const VerticalSpace(space: 20);
                            },
                          )),
                    )
                  : Expanded(
                      child: NoDataPlaceholder(
                        text: LocaleKeys.notifications_upto_date.tr(),
                      ),
                    ),
              SizedBox(
                height: 30.h,
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          return EmptyListPlaceholder(error);
        },
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      )),
    );
  }
}
