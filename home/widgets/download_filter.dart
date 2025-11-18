import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../shared/utils/date_time.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/padding.dart';
import '../../../shared/widgets/primary_text_field.dart';
import '../../../shared/widgets/toast.dart';
import '../../../translations/locale_keys.g.dart';
import '../home_extensions.dart';
import '../providers/filter_logs_providers.dart';
import '../providers/time_logs_providers.dart';

class DownloadFilter extends ConsumerStatefulWidget {
  const DownloadFilter({super.key});

  @override
  ConsumerState<DownloadFilter> createState() => _DownloadFilterState();
}

class _DownloadFilterState extends ConsumerState<DownloadFilter> {
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(downloadLogsProvider);
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: EdgeInsets.only(
              top: 30.h,
              left: 24.w,
              right: 24.w,
              bottom: 30.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.downloadLogFilter.tr(),
                  style: Theme.of(context).primaryTextTheme.displayMedium,
                ),
                const VerticalSpace(space: 30),
                Text(
                  LocaleKeys.date.tr(),
                  style: Theme.of(context).primaryTextTheme.displaySmall,
                ),
                const VerticalSpace(space: 10),
                Row(
                  children: [
                    Flexible(
                      child: PrimaryTextField(
                        controller: _startDateController,
                        hintText: LocaleKeys.start_date.tr(),
                        readOnly: true,
                        onTap: () async {
                          final startDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (startDate != null) {
                            _startDateController.text = yyyyMMdd(startDate);
                            ref
                                .read(modelLogFilterProvider.notifier)
                                .setStartDate(startDate);
                          }
                        },
                      ),
                    ),
                    const HorizontalSpace(space: 20),
                    Flexible(
                      child: PrimaryTextField(
                        controller: _endDateController,
                        hintText: LocaleKeys.end_date.tr(),
                        readOnly: true,
                        onTap: () async {
                          final endDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (endDate != null) {
                            _endDateController.text = yyyyMMdd(endDate);
                            ref
                                .read(modelLogFilterProvider.notifier)
                                .setEndDate(endDate);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Consumer(
                  builder: (_, ref, __) {
                    final activeFilters = ref.watch(modelLogFilterProvider);

                    return Button(
                      label: LocaleKeys.confirm.tr(),
                      isDisabled: activeFilters.activeFilters.isEmpty,
                      onPressed: () async {
                        bool hasPermission = await _requestWritePermission();
                        if (!hasPermission) return;

                        String path = await getPath(
                          activeFilters.startDate?.toString(),
                          activeFilters.endDate?.toString(),
                        );

                        ref.read(downloadLogsProvider.notifier).download(
                          path,
                          startDate: activeFilters.startDate,
                          endDate: activeFilters.endDate,
                          onSuccess: () {
                            context.pop();
                            showSuccessSnackBar(
                              context,
                              message: LocaleKeys.success_downloaded.tr(),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
  }

  Future<String> getPath(String? startDate, String? endDate) async {
    Directory? dir;
    String? path;

    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    }

    if (dir != null) {
      String newPath = dir.path;
      if (Platform.isAndroid) {
        newPath = "${dir.path.split("Android")[0]}SparTrans";
      }

      dir = Directory(newPath);

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      String fileName =
          "TF${startDate != null ? "-${parseDateToString(startDate)}" : ""}"
          "${endDate != null ? "-${parseDateToString(endDate)}" : ""}";

      int counter = 1;
      String uniqueFileName = fileName;
      while (await File("${dir.path}/$uniqueFileName.pdf").exists()) {
        uniqueFileName = "$fileName (${counter++})";
      }

      path = "${dir.path}/$uniqueFileName.pdf";
    }

    return path!;
  }

  Future<bool> _requestWritePermission() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    // check if android
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (Platform.isAndroid && androidInfo.version.sdkInt >= 29) {
        await Permission.manageExternalStorage.request();
      } else {
        await Permission.storage.request();
      }
    }
    return await Permission.storage.request().isGranted ||
        await Permission.manageExternalStorage.request().isGranted;
  }
}
