class RequestLeaveDto {
  final String type;
  final String reason;
  final DateTime? startDate;
  final DateTime? endDate;

  const RequestLeaveDto({
    required this.type,
    required this.reason,
    required this.startDate,
    required this.endDate,
  });

  const RequestLeaveDto.empty()
      : type = '',
        reason = '',
        startDate = null,
        endDate = null;

  RequestLeaveDto copyWith({
    String? type,
    String? reason,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return RequestLeaveDto(
      type: type ?? this.type,
      reason: reason ?? this.reason,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  bool get isValid => type.isNotEmpty && reason.isNotEmpty && startDate != null && endDate != null;
}
