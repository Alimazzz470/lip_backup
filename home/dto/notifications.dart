import 'package:equatable/equatable.dart';

class NotificationDto extends Equatable {
  final String? type;
  final String? createdAt;
  final String? updatedAt;
  final String? referenceKey;

  const NotificationDto({
    this.type,
    this.createdAt,
    this.updatedAt,
    this.referenceKey,
  });

  @override
  List<Object?> get props => [
        type,
        createdAt,
        updatedAt,
        referenceKey,
      ];

  const NotificationDto.empty()
      : type = null,
        createdAt = null,
        updatedAt = null,
        referenceKey = null;
}
