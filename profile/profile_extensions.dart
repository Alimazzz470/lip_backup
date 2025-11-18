import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';

import '../../shared/helpers/app_assets.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/utils/date_time.dart';
import '../../translations/locale_keys.g.dart';
import 'dto/filter.dart';

enum VehicleInspectionType {
  FRONT,
  BACK,
  LEFT,
  RIGHT,
}

extension VehicleInspectionTypeExtension on VehicleInspectionType {
  String get side {
    switch (this) {
      case VehicleInspectionType.FRONT:
        return LocaleKeys.front_side.tr();
      case VehicleInspectionType.BACK:
        return LocaleKeys.back_side.tr();
      case VehicleInspectionType.LEFT:
        return LocaleKeys.left_side.tr();
      case VehicleInspectionType.RIGHT:
        return LocaleKeys.right_side.tr();
    }
  }

  String get dbValue {
    switch (this) {
      case VehicleInspectionType.FRONT:
        return "front";
      case VehicleInspectionType.BACK:
        return "back";
      case VehicleInspectionType.LEFT:
        return "left";
      case VehicleInspectionType.RIGHT:
        return "right";
    }
  }
}

class VehicleInspection {
  final String label;
  final String imagePath;
  final String? selectedImagePath;
  final VehicleInspectionType type;

  const VehicleInspection({
    required this.label,
    required this.imagePath,
    this.selectedImagePath,
    required this.type,
  });

  VehicleInspection copyWith({
    String? selectedImagePath,
  }) {
    return VehicleInspection(
      label: label,
      imagePath: imagePath,
      selectedImagePath: selectedImagePath,
      type: type,
    );
  }
}

List<VehicleInspection> vehicleSides = [
  VehicleInspection(
    label: VehicleInspectionType.FRONT.side,
    imagePath: VEHICLE_FRONT_IMAGE,
    type: VehicleInspectionType.FRONT,
  ),
  VehicleInspection(
    label: VehicleInspectionType.BACK.side,
    imagePath: VEHICLE_BACK_IMAGE,
    type: VehicleInspectionType.BACK,
  ),
  VehicleInspection(
    label: VehicleInspectionType.LEFT.side,
    imagePath: VEHICLE_LEFT_IMAGE,
    type: VehicleInspectionType.LEFT,
  ),
  VehicleInspection(
    label: VehicleInspectionType.RIGHT.side,
    imagePath: VEHICLE_RIGHT_IMAGE,
    type: VehicleInspectionType.RIGHT,
  ),
];

extension FilterExtension on FilterDto {
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

enum AdvanceStatus {
  PENDING,
  APPROVED,
  REJECTED,
}

extension LeaveStatusExtension on AdvanceStatus {
  String get name {
    return switch (this) {
      AdvanceStatus.PENDING => LocaleKeys.pending.tr(),
      AdvanceStatus.APPROVED => LocaleKeys.approved.tr(),
      AdvanceStatus.REJECTED => LocaleKeys.rejected.tr(),
    };
  }

  Color get color {
    return switch (this) {
      AdvanceStatus.PENDING => WARNING_COLOR,
      AdvanceStatus.APPROVED => SUCCESS_COLOR,
      AdvanceStatus.REJECTED => ERROR_COLOR,
    };
  }
}
