import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/widgets/bottom_modal.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/no_data_placeholder.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/placeholders/empty_list_placeholder.dart';
import '../../../translations/locale_keys.g.dart';
import '../dto/leaves_filter.dart';
import '../leaves_extensions.dart';
import '../providers/filter_leaves_provider.dart';
import '../providers/get_leaves_provider.dart';
import '../widgets/filter_leaves_body.dart';
import '../widgets/leave_card.dart';

class AllLeavesPage extends ConsumerStatefulWidget {
  final LeavesFilterDto filters;

  const AllLeavesPage({
    required this.filters,
    super.key,
  });

  @override
  ConsumerState<AllLeavesPage> createState() => _AllLeavesPageState();
}

class _AllLeavesPageState extends ConsumerState<AllLeavesPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_loadMoreListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaveFilterProvider.notifier).setFilters(widget.filters);
    });
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
      ref.read(allLeavesProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.all_leaves.tr(),
          style: Theme.of(context).primaryTextTheme.displayLarge,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const VerticalSpace(space: 40),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
              ),
              child: Consumer(
                builder: (_, ref, __) {
                  final filters = ref.watch(leaveFilterProvider);

                  return Button(
                    label: LocaleKeys.filter.tr(),
                    onPressed: () {
                      showBottomModal(
                        context: context,
                        height: 600.h,
                        initCode: () {
                          ref
                              .read(modelLeaveFilterProvider.notifier)
                              .initialize(filters);
                        },
                        child: const FilterLeavesBody(),
                      );
                    },
                  );
                },
              ),
            ),
            const VerticalSpace(space: 10),
            Consumer(
              builder: (_, ref, __) {
                final filters = ref.watch(leaveFilterProvider);
                return filters.activeFilters.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                        ),
                        child: Wrap(
                          spacing: 10.w,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: filters.activeFilters.map((e) {
                            return Chip(
                              label: Text(e),
                            );
                          }).toList(),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
            const VerticalSpace(),
            Expanded(
              child: RefreshIndicator(
                backgroundColor: Colors.white,
                onRefresh: () async {
                  ref.invalidate(allLeavesProvider);
                },
                child: ref.watch(allLeavesProvider).when(
                  data: (leaves) {
                    if (leaves.data.isEmpty) {
                      return NoDataPlaceholder(text: LocaleKeys.no_leaves.tr());
                    }

                    return ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount:
                          leaves.data.length + (leaves.hasNextPage ? 1 : 0),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                      ),
                      itemBuilder: (context, index) {
                        if (index == leaves.data.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return LeaveCard(
                          leave: leaves.data[index],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const VerticalSpace(space: 20);
                      },
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
