import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../router/routes.dart';
import '../../../../shared/widgets/bottom_modal.dart';
import '../../../../shared/widgets/button.dart';
import '../../../../shared/widgets/padding.dart';
import '../../../../translations/locale_keys.g.dart';
import '../../profile_extensions.dart';
import '../../providers/filter_providers.dart';
import '../../providers/penalty_provider.dart';
import '../../widgets/filter.dart';
import '../../widgets/penalty_card.dart';

class PenaltyPage extends ConsumerStatefulWidget {
  const PenaltyPage({super.key});

  @override
  ConsumerState<PenaltyPage> createState() => _PenaltyPageState();
}

class _PenaltyPageState extends ConsumerState<PenaltyPage> {
  late final ScrollController _scrollController;
  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_loadMoreListener);
    super.initState();
  }

  void _loadMoreListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(penaltyProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_loadMoreListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.penalty.tr(),
          style: Theme.of(context).primaryTextTheme.displayLarge,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const VerticalSpace(space: 40),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
            ),
            child: Consumer(
              builder: (_, ref, __) {
                final filters = ref.watch(filterProvider);

                return Button(
                  label: LocaleKeys.filter.tr(),
                  onPressed: () {
                    showBottomModal(
                      context: context,
                      height: 450.w,
                      initCode: () {
                        ref
                            .read(modelFilterProvider.notifier)
                            .initialize(filters);
                      },
                      child: const Filter(),
                    );
                  },
                );
              },
            ),
          ),
          const VerticalSpace(),
          Consumer(
            builder: (_, ref, __) {
              final filters = ref.watch(filterProvider);
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
            child: Consumer(
              builder: (context, ref, child) {
                final penaltyList = ref.watch(penaltyProvider);

                return penaltyList.when(
                  data: (penalties) {
                    if (penalties.data.isEmpty) {
                      return Center(
                        child: Text(
                          LocaleKeys.no_penalties.tr(),
                          style: Theme.of(context).primaryTextTheme.bodyLarge,
                        ),
                      );
                    }
                    return RefreshIndicator(
                      backgroundColor: Colors.white,
                      onRefresh: () async {
                        ref.read(penaltyProvider.notifier).refresh();
                      },
                      child: ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          left: 24.w,
                          right: 24.w,
                          bottom: 40.h,
                        ),
                        itemCount: penalties.data.length +
                            (penalties.hasNextPage ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == penalties.data.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return PenaltyCard(
                            penalties.data[index],
                            onTap: () {
                              context.push(
                                Routes.penaltyDetailsUri(
                                  penalties.data[index].id,
                                ),
                                extra: penalties.data[index],
                              );
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const VerticalSpace(space: 15);
                        },
                      ),
                    );
                  },
                  error: (error, stack) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                      ),
                      child: Center(
                        child: Text(
                          error.toString(),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                  loading: () {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
