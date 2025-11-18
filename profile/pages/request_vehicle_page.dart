import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/utils/debounce.dart';
import '../../../shared/widgets/bottom_modal.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/placeholders/empty_list_placeholder.dart';
import '../../../shared/widgets/primary_dropdown.dart';
import '../../../shared/widgets/primary_text_field.dart';
import '../../../translations/locale_keys.g.dart';
import '../providers/request_vehicle_providers.dart';
import '../providers/search_vehicle_provider.dart';
import '../widgets/request_car_body.dart';
import '../widgets/vehicle_card.dart';

class RequestVehiclePage extends StatelessWidget {
  const RequestVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            LocaleKeys.request_car.tr(),
            style: Theme.of(context).primaryTextTheme.displayLarge,
          ),
        ),
        body: const Column(
          children: [
            VerticalSpace(space: 40),
            _Filter(),
            VerticalSpace(space: 30),
            _VehicleList(),
          ],
        ),
      ),
    );
  }
}

class _Filter extends ConsumerStatefulWidget {
  const _Filter({Key? key}) : super(key: key);

  @override
  ConsumerState<_Filter> createState() => _FilterState();
}

class _FilterState extends ConsumerState<_Filter> {
  late final Debounce _debounce;

  @override
  void initState() {
    super.initState();
    _debounce = Debounce();
  }

  @override
  void dispose() {
    _debounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24.w,
      ),
      child: Column(
        children: [
          PrimaryDropdown(
            hint: LocaleKeys.select_vehicle_type.tr(),
            options: ref.watch(vehicleTypeProvider).maybeWhen(
                  data: (types) => types,
                  orElse: () => [],
                ),
            onChanged: (typeId) {
              ref.read(searchVehicleProvider.notifier).search(
                    vehicleTypeId: typeId,
                  );
            },
          ),
          const VerticalSpace(space: 30),
          PrimaryTextField(
            label: LocaleKeys.search_plate.tr(),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 32.w,
            ),
            onChanged: (vehicleNumber) {
              _debounce(() {
                ref.read(searchVehicleProvider.notifier).search(
                      vehicleNumber: vehicleNumber,
                    );
              });
            },
          )
        ],
      ),
    );
  }
}

class _VehicleList extends ConsumerStatefulWidget {
  const _VehicleList({Key? key}) : super(key: key);

  @override
  ConsumerState<_VehicleList> createState() => _VehicleListState();
}

class _VehicleListState extends ConsumerState<_VehicleList> {
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
      ref.read(vehiclesProvider.notifier).loadMore();
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
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.w,
                        color: SUCCESS_COLOR,
                      ),
                      const HorizontalSpace(space: 15),
                      Text(
                        LocaleKeys.available.tr(),
                        style: Theme.of(context).primaryTextTheme.bodyLarge,
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.w,
                        color: ERROR_COLOR,
                      ),
                      const HorizontalSpace(space: 15),
                      Text(
                        LocaleKeys.occupied.tr(),
                        style: Theme.of(context)
                            .primaryTextTheme
                            .bodyLarge!
                            .copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const VerticalSpace(space: 30),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final vehicleList = ref.watch(vehiclesProvider);

                return vehicleList.when(
                  data: (vehicles) {
                    if (vehicles.data.isEmpty) {
                      return Center(
                        child: Text(
                          LocaleKeys.no_vehicles_found.tr(),
                          style: Theme.of(context).primaryTextTheme.bodyLarge,
                        ),
                      );
                    }
                    return RefreshIndicator(
                      backgroundColor: Colors.white,
                      onRefresh: () async {
                        ref.read(vehiclesProvider.notifier).refresh();
                      },
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.only(
                          left: 24.w,
                          right: 24.w,
                          bottom: 40.h,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 20.w,
                          mainAxisSpacing: 20.w,
                          childAspectRatio: 1,
                          mainAxisExtent: 130.w,
                        ),
                        itemCount: vehicles.data.length +
                            (vehicles.hasNextPage ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == vehicles.data.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return VehicleCard(
                            plate: vehicles.data[index].vehicleNumber,
                            type: vehicles.data[index].vehicleType.name,
                            isAvailable: vehicles.data[index].user == null,
                            onTap: () {
                              showBottomModal(
                                height: 600.w,
                                context: context,
                                child: RequestCarBody(
                                    vehicle: vehicles.data[index]),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                  error: (error, stack) {
                    return EmptyListPlaceholder(error);
                  },
                  loading: () {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
