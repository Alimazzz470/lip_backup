import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Color;

import '../../shared/theme/app_colors.dart';
import '../../shared/utils/date_time.dart';
import '../../translations/locale_keys.g.dart';
import 'dto/leaves_filter.dart';

enum LeaveStatus {
  PENDING,
  APPROVED,
  REJECTED,
}

extension LeaveStatusExtension on LeaveStatus {
  String get name {
    return switch (this) {
      LeaveStatus.PENDING => LocaleKeys.pending.tr(),
      LeaveStatus.APPROVED => LocaleKeys.approved.tr(),
      LeaveStatus.REJECTED => LocaleKeys.rejected.tr(),
    };
  }

  Color get color {
    return switch (this) {
      LeaveStatus.PENDING => WARNING_COLOR,
      LeaveStatus.APPROVED => SUCCESS_COLOR,
      LeaveStatus.REJECTED => ERROR_COLOR,
    };
  }
}

extension FilterLeaveExtension on LeavesFilterDto {
  List<String> get activeFilters {
    final filters = <String>[];
    if (status != null) {
      filters.add("${LocaleKeys.status.tr()}: $status");
    }
    if (type != null) {
      filters.add("${LocaleKeys.type.tr()}: ${type?.label}");
    }

    if (startDate != null && endDate != null) {
      filters.add(
          "${LocaleKeys.from.tr()}: ${yyyyMMdd(startDate!)} ${LocaleKeys.to.tr()}: ${yyyyMMdd(endDate!)}");
    } else {
      if (startDate != null) {
        filters.add("${LocaleKeys.from.tr()}: ${yyyyMMdd(startDate!)}");
      }

      if (endDate != null) {
        filters.add("${LocaleKeys.to.tr()}: ${yyyyMMdd(endDate!)}");
      }
    }

    return filters;
  }
}
