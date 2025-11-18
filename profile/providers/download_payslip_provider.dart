import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/dto/query_params.dart';
import '../../../core/services/image_helpers.dart';
import '../../../shared/utils/result.dart';
import '../../../shared/utils/typedef.dart';
import '../providers.dart';

final downloadPayslipProvider =
    NotifierProvider<DownloadPayslipNotifier, bool>(DownloadPayslipNotifier.new);

class DownloadPayslipNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> download({
    required OnSuccessCallback onSuccess,
    required OnErrorCallback onError,
  }) async {
    final profileRepository = ref.read(profileRepositoryProvider);

    final monthYear = ref.read(selectMonthYearProvider);

    state = true;
    final result = await profileRepository.getPayslip(
      QueryParams(
        month: monthYear.month,
        year: monthYear.year,
      ),
    );

    switch (result) {
      case Success(value: final url):
        await downloadFile(
          fileName: "Payslip-${monthYear.month}-${monthYear.year}.pdf",
          downloadUri: url,
        );
        state = false;
        onSuccess(url);
      case Failure(exception: final exception):
        state = false;
        onError(exception);
        break;
      case Canceled():
        break;
    }
  }
}

class PayslipFilterDto {
  final String month;
  final String year;

  const PayslipFilterDto({
    required this.month,
    required this.year,
  });

  factory PayslipFilterDto.empty() {
    return const PayslipFilterDto(
      month: "",
      year: "",
    );
  }

  bool get isDisabled => month.isEmpty || year.isEmpty;

  PayslipFilterDto copyWith({
    String? month,
    String? year,
  }) {
    return PayslipFilterDto(
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}

final selectMonthYearProvider =
    NotifierProvider.autoDispose<SelectMonthYearNotifier, PayslipFilterDto>(
        SelectMonthYearNotifier.new);

class SelectMonthYearNotifier extends AutoDisposeNotifier<PayslipFilterDto> {
  @override
  PayslipFilterDto build() => PayslipFilterDto.empty();

  void setMonth(String month) {
    state = state.copyWith(month: month);
  }

  void setYear(String year) {
    state = state.copyWith(year: year);
  }
}
