import 'package:easy_localization/easy_localization.dart';

import '../../shared/utils/date_time.dart';
import '../../translations/locale_keys.g.dart';
import 'dto/log_filter.dart';

extension FilterLogExtension on LogFilterDto {
  List<String> get activeFilters {
    final filters = <String>[];

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
